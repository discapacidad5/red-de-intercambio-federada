-- =============================================================================
-- Migración 199: Reconstrucción limpia del catálogo federado (__FEDERATION__)
-- con precios energéticos reales (LCA: Agribalyse, Ecoinvent, ICE Database, FAO),
-- eliminación de productos duplicados y compuestos plantilla en 0 TQ, y
-- corrección definitiva de sincronización con el Punto de Venta (POS) Android.
-- =============================================================================

-- 1. Asegurar columna role en users para evitar errores SQL (SQLSTATE 42703)
ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(50) NOT NULL DEFAULT 'user';
UPDATE users SET role = 'super_admin' WHERE COALESCE(is_super_admin, false) = true AND role = 'user';

-- 2. Función canónica para calcular el precio de cualquier variante en CENTAVOS
--    sin multiplicar erróneamente por 100 los precios < 50 centavos (< 0.50 TQ).
CREATE OR REPLACE FUNCTION compute_federation_variant_price_cents(
    fed_ppu_cents NUMERIC,
    fed_ppk_tq NUMERIC,
    fed_weight_kg NUMERIC,
    fed_unit TEXT,
    fed_base_unit TEXT,
    sell_unit TEXT,
    sell_qty NUMERIC
) RETURNS NUMERIC AS $$
DECLARE
    ppu_cents NUMERIC := COALESCE(fed_ppu_cents, 0);
    ppk_tq NUMERIC := COALESCE(fed_ppk_tq, 0);
    w_kg NUMERIC := COALESCE(fed_weight_kg, 0);
    fu TEXT := LOWER(TRIM(COALESCE(NULLIF(fed_unit, ''), 'unidad')));
    su TEXT := LOWER(TRIM(COALESCE(NULLIF(sell_unit, ''), fu)));
    qty NUMERIC := CASE WHEN COALESCE(sell_qty, 0) > 0 THEN sell_qty ELSE 1 END;
    base_unit_cents NUMERIC := 0;
    factor_to_base NUMERIC := 1;
BEGIN
    -- Solo convertir a centavos si viene con decimales fraccionarios
    IF ppu_cents > 0 AND ppu_cents <> TRUNC(ppu_cents) THEN
        ppu_cents := ROUND(ppu_cents * 100.0);
    END IF;

    -- Precio en centavos por 1 unidad base (kg, L, m, unidad)
    IF w_kg > 0 AND ppu_cents > 0 THEN
        base_unit_cents := ppu_cents / w_kg;
    ELSIF ppk_tq > 0 THEN
        IF ppk_tq >= 100 AND ppu_cents > 0 AND ABS(ppk_tq - ppu_cents) < 1 THEN
            base_unit_cents := ppk_tq;
        ELSE
            base_unit_cents := ppk_tq * 100.0;
        END IF;
    ELSE
        base_unit_cents := ppu_cents;
    END IF;

    -- Si la unidad de venta es la misma que la unidad de la Federación
    IF su = fu THEN
        IF w_kg > 1 AND ABS(qty - w_kg) < 0.001 AND su IN ('saco', 'bulto', 'paquete', 'frasco', 'botella', 'canasta') THEN
            RETURN ROUND(ppu_cents);
        END IF;
        RETURN ROUND(ppu_cents * qty);
    END IF;

    -- Conversión entre unidades por división/multiplicación exacta
    IF su IN ('saco', 'bulto') THEN
        factor_to_base := CASE WHEN w_kg > 0 THEN w_kg ELSE 25.0 END;
        IF w_kg > 1 AND ABS(qty - w_kg) < 0.001 THEN
            qty := 1.0;
        END IF;
    ELSIF su = 'quintal' THEN
        factor_to_base := 46.0;
    ELSIF su = 'arroba' THEN
        factor_to_base := 11.5;
    ELSIF su IN ('kg', 'kilo', 'kilogramo', 'kilogramos', 'l', 'litro', 'litros', 'm', 'metro', 'metros') THEN
        factor_to_base := 1.0;
    ELSIF su IN ('g', 'gr', 'gramo', 'gramos', 'ml', 'mililitro', 'mililitros', 'cc', 'mm', 'milimetro', 'milimetros') THEN
        IF qty >= 1.0 THEN
            factor_to_base := 1.0 / 1000.0;
        ELSE
            factor_to_base := 1.0;
        END IF;
    ELSIF su IN ('mg', 'miligramo', 'miligramos') THEN
        IF qty >= 1.0 THEN
            factor_to_base := 1.0 / 1000000.0;
        ELSE
            factor_to_base := 1.0;
        END IF;
    ELSIF su IN ('cm', 'centimetro', 'centimetros', 'centímetro') THEN
        IF qty >= 1.0 THEN
            factor_to_base := 1.0 / 100.0;
        ELSE
            factor_to_base := 1.0;
        END IF;
    ELSIF su IN ('lb', 'libra', 'libras') THEN
        IF qty >= 1.0 OR ABS(qty - 0.4536) > 0.001 THEN
            factor_to_base := 0.45359237;
        ELSE
            factor_to_base := 1.0;
        END IF;
    ELSIF su IN ('oz', 'onza', 'onzas') THEN
        IF qty >= 1.0 OR ABS(qty - 0.02835) > 0.001 THEN
            factor_to_base := 0.0283495;
        ELSE
            factor_to_base := 1.0;
        END IF;
    ELSIF su IN ('galon', 'galón') THEN
        IF qty >= 1.0 OR ABS(qty - 3.78541) > 0.001 THEN
            factor_to_base := 3.78541;
        ELSE
            factor_to_base := 1.0;
        END IF;
    ELSIF su IN ('pulgada', 'pulgadas', 'in') THEN
        IF qty >= 1.0 OR ABS(qty - 0.0254) > 0.001 THEN
            factor_to_base := 0.0254;
        ELSE
            factor_to_base := 1.0;
        END IF;
    ELSIF su IN ('pie', 'pies', 'ft') THEN
        IF qty >= 1.0 OR ABS(qty - 0.3048) > 0.001 THEN
            factor_to_base := 0.3048;
        ELSE
            factor_to_base := 1.0;
        END IF;
    ELSIF su = 'docena' THEN
        IF fu = 'docena' THEN
            RETURN ROUND(ppu_cents * qty);
        ELSIF w_kg > 0 THEN
            factor_to_base := w_kg;
        ELSE
            factor_to_base := 12.0;
        END IF;
    ELSIF su IN ('media docena', 'media_docena') THEN
        IF fu = 'docena' THEN
            RETURN ROUND((ppu_cents / 2.0) * qty);
        ELSIF w_kg > 0 THEN
            factor_to_base := w_kg / 2.0;
        ELSE
            factor_to_base := 6.0;
        END IF;
    ELSIF su IN ('unidad', 'pieza', 'paquete', 'frasco', 'botella', 'bolsa', 'caja', 'manojo', 'atado', 'racimo', 'rollo', 'par', 'set', 'maceta', 'sobre', 'bloque', 'canasta') THEN
        IF fu = 'docena' THEN
            RETURN ROUND((ppu_cents / 12.0) * qty);
        END IF;
        RETURN ROUND(ppu_cents * qty);
    ELSE
        RETURN ROUND(ppu_cents * qty);
    END IF;

    RETURN ROUND(base_unit_cents * factor_to_base * qty);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 3. Remapear y eliminar productos duplicados y compuestos plantilla en 0 TQ
CREATE OR REPLACE FUNCTION merge_duplicate_product(dup_name TEXT, canon_name TEXT)
RETURNS VOID AS $$
DECLARE
    canon_id UUID;
    dup_rec RECORD;
BEGIN
    SELECT id INTO canon_id
    FROM products
    WHERE LOWER(TRIM(name)) = LOWER(TRIM(canon_name))
    ORDER BY (node_domain = '__FEDERATION__') DESC, is_approved DESC, created_at ASC
    LIMIT 1;

    IF canon_id IS NULL THEN
        RETURN;
    END IF;

    FOR dup_rec IN
        SELECT id FROM products
        WHERE LOWER(TRIM(name)) = LOWER(TRIM(dup_name))
          AND id <> canon_id
    LOOP
        UPDATE store_items SET product_id = canon_id WHERE product_id = dup_rec.id;

        DELETE FROM product_compositions pc_dup
        WHERE pc_dup.product_id = dup_rec.id
          AND EXISTS (
              SELECT 1 FROM product_compositions pc_can
              WHERE pc_can.product_id = canon_id
                AND pc_can.component_product_id = pc_dup.component_product_id
          );
        UPDATE product_compositions SET product_id = canon_id WHERE product_id = dup_rec.id;

        DELETE FROM product_compositions pc_dup
        WHERE pc_dup.component_product_id = dup_rec.id
          AND EXISTS (
              SELECT 1 FROM product_compositions pc_can
              WHERE pc_can.product_id = pc_dup.product_id
                AND pc_can.component_product_id = canon_id
          );
        UPDATE product_compositions SET component_product_id = canon_id WHERE component_product_id = dup_rec.id;

        UPDATE pos_transaction_items SET product_id = canon_id WHERE product_id = dup_rec.id;
        UPDATE external_purchases SET product_id = canon_id WHERE product_id = dup_rec.id;
        UPDATE external_sales SET product_id = canon_id WHERE product_id = dup_rec.id;
        UPDATE external_bridge_operations SET product_id = canon_id WHERE product_id = dup_rec.id;
        UPDATE conversion_factor SET reference_product_id = canon_id WHERE reference_product_id = dup_rec.id;
        UPDATE products SET source_product_id = canon_id WHERE source_product_id = dup_rec.id;

        DELETE FROM products WHERE id = dup_rec.id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT merge_duplicate_product('Huevos Frescos', 'Huevos Criollos (Semilibres)');
SELECT merge_duplicate_product('Fertilizantes Organicos', 'Abonos Organicos');
SELECT merge_duplicate_product('Carne de Res', 'Carnes de Vacuno');
SELECT merge_duplicate_product('Mantequilla y Queso', 'Lacteos Artesanales');
SELECT merge_duplicate_product('Plantas Medicinales (Maceta)', 'Plantulas Medicinales y Aromaticas');
SELECT merge_duplicate_product('Semillas Criollas Ancestrales', 'Semillas Criollas Adaptadas');
SELECT merge_duplicate_product('Cacao Puro, Chocolates y Cafe de Montana', 'Cacao, Chocolate y Cafe');
SELECT merge_duplicate_product('La Tradicional Cafunga de Barlovento', 'Cafunga de Barlovento');
SELECT merge_duplicate_product('Trabajo de Carpinteria (hora)', 'Carpinteria y Ebanisteria');
SELECT merge_duplicate_product('Trabajo de Costura (hora)', 'Costura y Confeccion');
SELECT merge_duplicate_product('Combustibles para Transporte', 'Diesel Agricola');
SELECT merge_duplicate_product('Sombreros y Gorros', 'Sombrero de Paja (0.2 kg)');

-- Compuestos plantilla con precio 0 de la migración 095 -> remapear al rubro real y eliminar
SELECT merge_duplicate_product('Biofertilizantes Artesanales', 'Bioinsumos y Preparados');
SELECT merge_duplicate_product('Controles Biologicos', 'Plaguicidas Naturales');
SELECT merge_duplicate_product('Chichas Artesanales', 'Bebidas Fermentadas');
SELECT merge_duplicate_product('Encurtidos Artesanales', 'Encurtidos y Salsas');
SELECT merge_duplicate_product('Infusiones Naturales Mezcladas', 'Infusiones y Tes');
SELECT merge_duplicate_product('Vinos Artesanales de Frutas', 'Bebidas Fermentadas');
SELECT merge_duplicate_product('Licores Artesanales', 'Licores y Destilados');
SELECT merge_duplicate_product('Cesteria Artesanal', 'Cesta Mediana (1 kg)');
SELECT merge_duplicate_product('Balsamos y Tinturas Naturales', 'Tinturas Madres y Botica Conuquera');
SELECT merge_duplicate_product('Cremas y Emulsiones Naturales', 'Cosmetica Natural sin Quimicos');
SELECT merge_duplicate_product('Mascarillas Faciales Naturales', 'Cosmetica Natural sin Quimicos');
SELECT merge_duplicate_product('Labiales Naturales', 'Cosmetica Natural sin Quimicos');
SELECT merge_duplicate_product('Aceite de Coco Cosmetico', 'Cosmetica Natural sin Quimicos');
SELECT merge_duplicate_product('Arcilla para la Piel', 'Arcilla para Ceramica (cruda)');
SELECT merge_duplicate_product('Plantas Ornamentales (Maceta)', 'Plantulas Medicinales y Aromaticas');
SELECT merge_duplicate_product('Plantas Frutales (Maceta)', 'Plantulas Medicinales y Aromaticas');
SELECT merge_duplicate_product('Matas de Moringa', 'Plantulas Medicinales y Aromaticas');
SELECT merge_duplicate_product('Moringa en Polvo', 'Hierbas Medicinales Secas');
SELECT merge_duplicate_product('Gotas de Nin', 'Tinturas Madres y Botica Conuquera');
SELECT merge_duplicate_product('Harina Buen Pan', 'Harinas Integrales');
SELECT merge_duplicate_product('Pastelitos de Vegetales Artesanales', 'Panaderia y Masas Caseras');
SELECT merge_duplicate_product('Hamburguesas Vegetarianas Artesanales', 'Croquetas de Soya Artesanales');
SELECT merge_duplicate_product('Tacos de Granos Artesanales', 'Torticas Veganas Artesanales');
SELECT merge_duplicate_product('Frutos Deshidratados Artesanales', 'Dulces y Conservas Tradicionales');
SELECT merge_duplicate_product('Ajiaco Artesanal', 'Panaderia y Masas Caseras');
SELECT merge_duplicate_product('Horno de Barro Artesanal', 'Ladrillo de Arcilla');

-- Eliminar cualquier producto plantilla que haya quedado con precio 0 y sin uso en tiendas
UPDATE external_purchases SET product_id = NULL WHERE product_id IN (SELECT id FROM products WHERE COALESCE(price_per_unit, 0) <= 0);
UPDATE external_sales SET product_id = NULL WHERE product_id IN (SELECT id FROM products WHERE COALESCE(price_per_unit, 0) <= 0);
UPDATE external_bridge_operations SET product_id = NULL WHERE product_id IN (SELECT id FROM products WHERE COALESCE(price_per_unit, 0) <= 0);
UPDATE conversion_factor SET reference_product_id = NULL WHERE reference_product_id IN (SELECT id FROM products WHERE COALESCE(price_per_unit, 0) <= 0);
UPDATE products SET source_product_id = NULL WHERE source_product_id IN (SELECT id FROM products WHERE COALESCE(price_per_unit, 0) <= 0);

DELETE FROM products p
WHERE COALESCE(p.price_per_unit, 0) <= 0
  AND NOT EXISTS (SELECT 1 FROM store_items si WHERE si.product_id = p.id)
  AND NOT EXISTS (SELECT 1 FROM product_compositions pc WHERE pc.product_id = p.id OR pc.component_product_id = p.id)
  AND NOT EXISTS (SELECT 1 FROM pos_transaction_items pti WHERE pti.product_id = p.id);

-- 4. Tabla maestra de precios energéticos reales (LCA) para todo el catálogo de __FEDERATION__
DROP TABLE IF EXISTS clean_federation_prices;
CREATE TABLE clean_federation_prices (
    name TEXT PRIMARY KEY,
    unit TEXT NOT NULL,
    base_unit TEXT NOT NULL,
    weight_kg NUMERIC NOT NULL,
    price_per_kg NUMERIC NOT NULL,
    price_per_unit_cents NUMERIC NOT NULL,
    new_description TEXT
);

INSERT INTO clean_federation_prices (name, unit, base_unit, weight_kg, price_per_kg, price_per_unit_cents, new_description) VALUES
-- Trabajo y Servicios
('Jornal Agricola', 'hora', 'hora', 1, 1.00, 100, NULL),
('Jornada Agricola Completa', 'jornada', 'jornada', 1, 5.00, 500, NULL),
('Jornada de Trabajo General', 'jornada', 'jornada', 1, 8.00, 800, NULL),
('Limpieza de Espacios', 'hora', 'hora', 1, 1.00, 100, NULL),
('Trabajo Administrativo y Gestion', 'hora', 'hora', 1, 1.00, 100, NULL),
('Jornada de Trabajo Tecnico', 'jornada', 'jornada', 1, 24.00, 2400, NULL),
('Albanileria y Obra Menor', 'hora', 'hora', 1, 3.00, 300, NULL),
('Carpinteria y Ebanisteria', 'hora', 'hora', 1, 3.00, 300, NULL),
('Mecanica General', 'hora', 'hora', 1, 3.00, 300, NULL),
('Electricidad y Electrotecnia', 'hora', 'hora', 1, 3.00, 300, NULL),
('Plomeria y Fontaneria', 'hora', 'hora', 1, 3.00, 300, NULL),
('Reparacion de Computadoras', 'hora', 'hora', 1, 3.00, 300, NULL),
('Reparacion de Electrodomesticos', 'hora', 'hora', 1, 3.00, 300, NULL),
('Reparacion de Telefonos', 'hora', 'hora', 1, 3.00, 300, NULL),
('Mantenimiento de Sistemas Solares', 'hora', 'hora', 1, 3.00, 300, NULL),
('Mantenimiento de Vehiculos', 'hora', 'hora', 1, 3.00, 300, NULL),
('Terapias Manuales y Alternativas', 'sesion', 'sesion', 1, 3.00, 300, NULL),
('Consulta Medica y Odontologica', 'sesion', 'sesion', 1, 3.00, 300, NULL),
('Clases y Tutorias', 'hora', 'hora', 1, 3.00, 300, NULL),
('Clases de Musica', 'hora', 'hora', 1, 3.00, 300, NULL),
('Talleres de Oficios', 'hora', 'hora', 1, 3.00, 300, NULL),
('Talleres de Agroecologia', 'hora', 'hora', 1, 3.00, 300, NULL),
('Talleres de Salud Comunitaria', 'hora', 'hora', 1, 3.00, 300, NULL),
('Alfabetizacion y Educacion Basica', 'hora', 'hora', 1, 3.00, 300, NULL),
('Animacion y Cuentacuentos', 'hora', 'hora', 1, 3.00, 300, NULL),
('Transporte de Carga', 'viaje', 'viaje', 1, 5.00, 500, NULL),
('Pasaje de Personas', 'viaje', 'viaje', 1, 1.00, 100, NULL),
('Servicio de Arriero', 'jornada', 'jornada', 1, 20.00, 2000, NULL),
('Peluqueria y Barberia', 'sesion', 'sesion', 1, 2.00, 200, NULL),
('Costura y Confeccion', 'hora', 'hora', 1, 2.00, 200, NULL),
('Reparacion y Adaptacion de Prendas', 'prenda', 'unidad', 1, 5.00, 500, NULL),
('Trabajo de Alfareria (hora)', 'hora', 'hora', 1, 1.00, 100, NULL),
('Trabajo de Cesteria (hora)', 'hora', 'hora', 1, 1.00, 100, NULL),
('Coccion de Ceramica en Horno (carga)', 'carga', 'carga', 1, 5.00, 500, NULL),
('Afilar y Mantener Herramientas', 'unidad', 'unidad', 1, 1.00, 100, NULL),
('Taller de Teatro', 'sesion', 'sesion', 1, 8.00, 800, NULL),
('Danza Tradicional', 'sesion', 'sesion', 1, 6.00, 600, NULL),
('Taller de Literatura', 'sesion', 'sesion', 1, 4.00, 400, NULL),
('Produccion Audiovisual', 'hora', 'hora', 1, 3.00, 300, NULL),
('Matematicas y Numeracion', 'sesion', 'sesion', 1, 4.00, 400, NULL),
('Tecnologia y Computacion', 'sesion', 'sesion', 1, 5.00, 500, NULL),
('Idiomas', 'sesion', 'sesion', 1, 4.00, 400, NULL),
('Apiterapia', 'sesion', 'sesion', 1, 3.00, 300, NULL),
('Homeopatia y Flores de Bach', 'sesion', 'sesion', 1, 2.00, 200, NULL),
('Software y Soporte', 'hora', 'hora', 1, 2.00, 200, NULL),
('Carga Animal', 'viaje', 'viaje', 1, 10.00, 1000, NULL),

-- Alimentos: Cosecha Fresca, Granos, Carnes, Lácteos, Transformados y Bebidas
('Hojas Verdes y Aromaticas', 'manojo', 'kg', 0.25, 2.00, 50, NULL),
('Tuberculos Ancestrales y Platanos', 'kg', 'kg', 1, 2.00, 200, NULL),
('Verduras y Hortalizas de Conuco', 'kg', 'kg', 1, 2.00, 200, NULL),
('Frutas de Temporada', 'kg', 'kg', 1, 2.00, 200, NULL),
('Raices y Bulbos', 'kg', 'kg', 1, 2.00, 200, NULL),
('Frutos Secos y Mani', 'kg', 'kg', 1, 11.00, 1100, NULL),
('Coco Fresco', 'unidad', 'kg', 1.5, 1.40, 210, NULL),
('Granos Basicos Criollos', 'kg', 'kg', 1, 3.00, 300, NULL),
('Arroz y Legumbres', 'kg', 'kg', 1, 4.00, 400, NULL),
('Harinas Integrales', 'kg', 'kg', 1, 4.00, 400, NULL),
('Cereales y Avena', 'kg', 'kg', 1, 4.20, 420, NULL),
('Panaderia y Masas Caseras', 'kg', 'kg', 1, 4.00, 400, NULL),
('Dulces y Conservas Tradicionales', 'frasco', 'kg', 0.5, 5.00, 250, NULL),
('Lacteos Artesanales', 'kg', 'kg', 1, 8.00, 800, NULL),
('Leche Fresca', 'L', 'L', 1, 2.00, 200, NULL),
('Cacao, Chocolate y Cafe', 'kg', 'kg', 1, 15.00, 1500, NULL),
('Encurtidos y Salsas', 'frasco', 'kg', 0.5, 5.00, 250, NULL),
('Miel Pura de Abejas', 'L', 'L', 1, 7.00, 700, NULL),
('Papelon y Panela', 'kg', 'kg', 1, 5.00, 500, NULL),
('Carnes de Pollo y Aves', 'kg', 'kg', 1, 5.00, 500, NULL),
('Carnes de Cerdo y Chivo', 'kg', 'kg', 1, 6.00, 600, NULL),
('Carnes de Vacuno', 'kg', 'kg', 1, 11.00, 1100, NULL),
('Pescados y Mariscos', 'kg', 'kg', 1, 7.00, 700, NULL),
('Huevos Comerciales (Jaula)', 'docena', 'kg', 0.65, 4.62, 300, NULL),
('Huevos Criollos (Semilibres)', 'docena', 'kg', 0.65, 9.23, 600, NULL),
('Huevos de Gallinas Felices (Pastoreo)', 'docena', 'kg', 0.65, 12.31, 800, NULL),
('Bebidas Fermentadas', 'L', 'L', 1, 3.00, 300, NULL),
('Infusiones y Tes', 'kg', 'kg', 1, 3.00, 300, NULL),
('Zumos y Jugos Naturales', 'L', 'L', 1, 1.10, 110, NULL),
('Refrescos Efervescentes', 'L', 'L', 1, 1.70, 170, NULL),
('Licores y Destilados', 'L', 'L', 1, 14.00, 1400, NULL),
('Bebidas Lacteas', 'L', 'L', 1, 1.70, 170, NULL),
('Aguas y Bebidas Hidratantes', 'L', 'L', 1, 0.80, 80, NULL),
('Especias y Condimentos', 'kg', 'kg', 1, 4.00, 400, NULL),
('Aceites y Vinagres', 'L', 'L', 1, 6.00, 600, NULL),
('Sal de Mar', 'kg', 'kg', 1, 0.80, 80, NULL),
('Canasta Basica Familiar Semanal', 'canasta', 'canasta', 10.5, 2.86, 3000, NULL),

-- Agricultura, Tierra, Bioinsumos y Riego
('Plantulas Medicinales y Aromaticas', 'maceta', 'unidad', 1, 1.00, 100, NULL),
('Semillas Criollas Adaptadas', 'sobre', 'unidad', 1, 1.00, 100, NULL),
('Estacas y Esquejes', 'unidad', 'unidad', 1, 1.00, 100, NULL),
('Abonos Organicos', 'saco', 'kg', 25, 0.09, 225, 'Compost maduro, humus de lombriz, estiercol curado, bokashi, gallinaza. Energia: ~0.3 MJ/kg = 0.09 kWh/kg (proceso de descomposicion controlada). Un saco de ~25 kg = 2.25 kWh. Fuente: Nigeria organic fertilizer study, Italy on-farm compost LCA.'),
('Bioinsumos y Preparados', 'L', 'L', 1, 3.00, 300, NULL),
('Tierra Fertil y Sustratos', 'saco', 'kg', 20, 0.05, 100, 'Tierra preparada, sustrato para semilleros, turba, arena de rio. Energia: ~0.18 MJ/kg = 0.05 kWh/kg. Un saco de 20 kg = 1.00 kWh.'),
('Plaguicidas Naturales', 'L', 'L', 1, 2.00, 200, NULL),
('Hongos Comestibles', 'kg', 'kg', 1, 3.00, 300, NULL),
('Humus de Lombriz Solido', 'kg', 'kg', 1, 0.60, 60, 'Humus de lombriz solido. Vermicompostaje con Eisenia foetida, 2-3 meses. Energia: LCA vermicompostaje 2 MJ/kg = 0.60 kWh/kg. Precio de referencia: 0.60 TQ/kg. Fuente: MDPI, scielo.org.mx. Documentado en Feria Conuquera (Lombriz Roja Urbana).'),
('Humus de Lombriz Liquido', 'L', 'L', 1, 0.30, 30, 'Humus de lombriz liquido (lixiviado). Energia: 1 MJ/L = 0.30 kWh/L. Precio de referencia: 0.30 TQ/L. Presentaciones: 500cc, 1000cc, 1500cc. Fuente: Lombriz Roja Urbana. Documentado en Feria Conuquera.'),
('Pie de Cria de Lombriz Roja Californiana', 'kg', 'kg', 1, 0.80, 80, 'Pie de cria de lombriz roja californiana (Eisenia foetida). Energia: 3 MJ/kg = 0.80 kWh/kg. Precio de referencia: 0.80 TQ/kg. Presentaciones: 300g, 400g, 1.5kg, 2kg. Fuente: Lombriz Roja Urbana. Documentado en Feria Conuquera.'),
('Compost Maduro Artesanal', 'kg', 'kg', 1, 0.40, 40, 'Compost maduro artesanal. Compostaje 2-6 meses. Energia: LCA compostaje 1.5 MJ/kg = 0.40 kWh/kg. Precio de referencia: 0.40 TQ/kg. Fuente: MDPI. Documentado en Feria Conuquera.'),
('Microorganismos de Montana', 'L', 'L', 1, 0.60, 60, 'Microorganismos de montana (MM). Fermentacion de lactobacilos y levaduras con melaza. Energia: 2 MJ/L = 0.60 kWh/L. Precio de referencia: 0.60 TQ/L. Fuente: Lombriz Roja Urbana. Documentado en Feria Conuquera.'),
('Manguera de Riego PVC 1m', 'metro', 'm', 1, 0.90, 90, NULL),
('Aspersor de Riego', 'unidad', 'unidad', 1, 0.50, 50, NULL),
('Gotero de Riego', 'unidad', 'unidad', 1, 0.10, 10, NULL),
('Bomba Manual de Agua', 'unidad', 'unidad', 1, 12.00, 1200, NULL),
('Tanque de Agua 200L', 'unidad', 'unidad', 1, 73.00, 7300, NULL),
('Tanque de Agua 1000L', 'unidad', 'unidad', 1, 365.00, 36500, NULL),

-- Salud y Medicina
('Tinturas Madres y Botica Conuquera', 'frasco', 'unidad', 1, 8.00, 800, NULL),
('Cosmetica Natural sin Quimicos', 'unidad', 'unidad', 1, 5.00, 500, NULL),
('Hierbas Medicinales Secas', 'kg', 'kg', 1, 3.00, 300, NULL),
('Jabones y Productos de Higiene', 'unidad', 'unidad', 1, 3.00, 300, NULL),
('Detergentes y Suavizantes Naturales', 'L', 'L', 1, 5.00, 500, NULL),
('Vendas y Gasas (Paquete)', 'paquete', 'unidad', 1, 3.00, 300, NULL),
('Alcohol Medicinal 1L', 'L', 'L', 1, 1.00, 100, NULL),
('Yodo (Frasco 30ml)', 'frasco', 'unidad', 1, 1.00, 100, NULL),
('Tijeras de Primeros Auxilios', 'unidad', 'unidad', 1, 2.00, 200, NULL),
('Apositos y Tiritas (Caja)', 'caja', 'unidad', 1, 1.00, 100, NULL),

-- Textiles, Artesanía y Materiales
('Tela de Algodon Cruda (kg)', 'kg', 'kg', 1, 40.00, 4000, NULL),
('Lana Cruda para Tejer (kg)', 'kg', 'kg', 1, 19.00, 1900, NULL),
('Hilo de Algodon (rollo 100g)', 'rollo', 'kg', 0.10, 40.00, 400, NULL),
('Camisa de Algodon Artesanal (0.3 kg)', 'unidad', 'unidad', 0.30, 53.33, 1600, NULL),
('Pantalon de Algodon Artesanal (0.5 kg)', 'unidad', 'unidad', 0.50, 50.00, 2500, NULL),
('Frazada de Lana Artesanal (1.5 kg)', 'unidad', 'unidad', 1.50, 24.67, 3700, NULL),
('Hamaca de Cañamo (1.2 kg)', 'unidad', 'unidad', 1.20, 25.00, 3000, NULL),
('Calzado Textil', 'par', 'unidad', 1, 8.00, 800, NULL),
('Arcilla para Ceramica (cruda)', 'kg', 'kg', 1, 0.70, 70, NULL),
('Madera Blanda para Tallado', 'kg', 'kg', 1, 0.08, 8, NULL),
('Madera Dura para Muebles', 'kg', 'kg', 1, 0.56, 56, NULL),
('Fibra Vegetal para Cesteria', 'kg', 'kg', 1, 0.14, 14, NULL),
('Taza de Barro (0.3 kg)', 'unidad', 'unidad', 0.30, 6.67, 200, NULL),
('Plato de Barro (0.5 kg)', 'unidad', 'unidad', 0.50, 6.00, 300, NULL),
('Olla de Barro (2 kg)', 'unidad', 'unidad', 2.00, 4.00, 800, NULL),
('Cantarola de Barro (5 kg)', 'unidad', 'unidad', 5.00, 3.00, 1500, NULL),
('Maceta de Arcilla Pequena (0.5 kg)', 'unidad', 'unidad', 0.50, 6.00, 300, NULL),
('Maceta de Arcilla Mediana (2 kg)', 'unidad', 'unidad', 2.00, 4.00, 800, NULL),
('Maceta de Arcilla Grande (5 kg)', 'unidad', 'unidad', 5.00, 3.00, 1500, NULL),
('Cuchara de Palo (0.1 kg)', 'unidad', 'unidad', 0.10, 10.00, 100, NULL),
('Mortero de Madera (1 kg)', 'unidad', 'unidad', 1.00, 3.00, 300, NULL),
('Silla Rustica de Madera (8 kg)', 'unidad', 'unidad', 8.00, 1.38, 1100, NULL),
('Mesa Rustica de Madera (20 kg)', 'unidad', 'unidad', 20.00, 1.15, 2300, NULL),
('Banco Rustico de Madera (12 kg)', 'unidad', 'unidad', 12.00, 1.17, 1400, NULL),
('Cama Rustica de Madera (35 kg)', 'unidad', 'unidad', 35.00, 1.00, 3500, NULL),
('Canasto Pequeno (0.3 kg)', 'unidad', 'unidad', 0.30, 6.67, 200, NULL),
('Cesta Mediana (1 kg)', 'unidad', 'unidad', 1.00, 4.00, 400, NULL),
('Sombrero de Paja (0.2 kg)', 'unidad', 'unidad', 0.20, 25.00, 500, NULL),
('Cuero Artesanal', 'kg', 'kg', 1, 24.00, 2400, NULL),
('Calzado de Cuero', 'par', 'unidad', 1, 22.00, 2200, NULL),
('Metal Forjado', 'kg', 'kg', 1, 8.00, 800, NULL),
('Vidrio Soplado', 'unidad', 'unidad', 1, 7.00, 700, NULL),

-- Construcción
('Bloques, Adobe y Bahareque', 'unidad', 'unidad', 1, 1.00, 100, NULL),
('Madera de Construccion', 'kg', 'kg', 1, 2.36, 236, NULL),
('Piedra y Agregados', 'kg', 'kg', 1, 0.05, 5, NULL),
('Hormigon Estructural', 'kg', 'kg', 1, 0.43, 43, NULL),
('Ladrillo de Arcilla', 'unidad', 'unidad', 1, 1.32, 132, NULL),
('Bloque de Paja', 'bloque', 'unidad', 1, 0.25, 25, NULL),
('Pinturas y Recubrimientos Naturales', 'L', 'L', 1, 4.00, 400, NULL),
('Acero Reciclado', 'kg', 'kg', 1, 5.56, 556, NULL),
('Acero Virgen', 'kg', 'kg', 1, 9.72, 972, NULL),
('Aluminio', 'kg', 'kg', 1, 53.60, 5360, NULL),
('Vidrio Plano', 'kg', 'kg', 1, 4.17, 417, NULL),
('Tuberia PVC', 'kg', 'kg', 1, 10.00, 1000, NULL),
('Impermeabilizantes', 'L', 'L', 1, 4.00, 400, NULL),
('Revestimientos y Estucos', 'kg', 'kg', 1, 1.40, 140, NULL),
('Carpinteria de Obra', 'unidad', 'unidad', 1, 22.00, 2200, NULL),

-- Energía y Combustibles
('Panel Solar Fotovoltaico', 'm2', 'unidad', 1, 1319.00, 131900, NULL),
('Lena Seca para Cocinar', 'kg', 'kg', 1, 4.00, 400, NULL),
('Carbon Vegetal', 'kg', 'kg', 1, 6.00, 600, NULL),
('Diesel Agricola', 'L', 'L', 1, 12.00, 1200, NULL),
('Gasolina', 'kg', 'kg', 1, 13.00, 1300, NULL),
('Gas GLP', 'kg', 'kg', 1, 14.00, 1400, NULL),
('Biomasa Seca (Pellets)', 'kg', 'kg', 1, 4.00, 400, NULL),
('Energia Eolica', 'unidad', 'unidad', 1, 139.00, 13900, NULL),
('Energia Hidraulica', 'unidad', 'unidad', 1, 222.00, 22200, NULL),

-- Herramientas, Tecnología, Transporte, Cultura y Recursos
('Machete', 'unidad', 'unidad', 1, 4.00, 400, NULL),
('Pala', 'unidad', 'unidad', 1, 9.00, 900, NULL),
('Pico', 'unidad', 'unidad', 1, 12.00, 1200, NULL),
('Rastrillo', 'unidad', 'unidad', 1, 7.00, 700, NULL),
('Azadon', 'unidad', 'unidad', 1, 6.00, 600, NULL),
('Martillo', 'unidad', 'unidad', 1, 2.00, 200, NULL),
('Serrucho', 'unidad', 'unidad', 1, 3.00, 300, NULL),
('Lima', 'unidad', 'unidad', 1, 2.00, 200, NULL),
('Destornillador', 'unidad', 'unidad', 1, 1.00, 100, NULL),
('Alicates', 'unidad', 'unidad', 1, 2.00, 200, NULL),
('Instrumentos de Medicion', 'unidad', 'unidad', 1, 6.00, 600, NULL),
('Herramientas de Corte', 'unidad', 'unidad', 1, 4.00, 400, NULL),
('Taladro Electrico', 'unidad', 'unidad', 1, 100.00, 10000, NULL),
('Sierra Circular', 'unidad', 'unidad', 1, 120.00, 12000, NULL),
('Amoladora', 'unidad', 'unidad', 1, 80.00, 8000, NULL),
('Lijadora Electrica', 'unidad', 'unidad', 1, 60.00, 6000, NULL),
('Soldadora Electrica', 'unidad', 'unidad', 1, 200.00, 20000, NULL),
('Telefono Inteligente', 'unidad', 'unidad', 1, 278.00, 27800, NULL),
('Computadora Portatil', 'unidad', 'unidad', 1, 1250.00, 125000, NULL),
('Computadora de Sobremesa', 'unidad', 'unidad', 1, 579.00, 57900, NULL),
('Monitor LCD', 'unidad', 'unidad', 1, 268.00, 26800, NULL),
('Lavadora Domestica', 'unidad', 'unidad', 1, 1083.00, 108300, NULL),
('Refrigerador Domestico', 'unidad', 'unidad', 1, 1639.00, 163900, NULL),
('Cafetera Electrica', 'unidad', 'unidad', 1, 51.00, 5100, NULL),
('Secador de Pelo', 'unidad', 'unidad', 1, 22.00, 2200, NULL),
('Cable Electrico (metro)', 'metro', 'm', 1, 1.00, 100, NULL),
('Resistencias (Paquete 10)', 'paquete', 'unidad', 1, 1.00, 100, NULL),
('Capacitores (Paquete 10)', 'paquete', 'unidad', 1, 1.00, 100, NULL),
('Conectores (Paquete)', 'paquete', 'unidad', 1, 2.00, 200, NULL),
('Soldadura Electronica (Rollo)', 'rollo', 'unidad', 1, 3.00, 300, NULL),
('Plaquetas PCB (Unidad)', 'unidad', 'unidad', 1, 2.00, 200, NULL),
('Fusibles (Paquete 10)', 'paquete', 'unidad', 1, 1.00, 100, NULL),
('Equipos de Red', 'unidad', 'unidad', 1, 33.00, 3300, NULL),
('Bicicleta Completa', 'unidad', 'unidad', 1, 100.00, 10000, NULL),
('Llanta de Bicicleta', 'unidad', 'unidad', 1, 7.00, 700, NULL),
('Cadena de Bicicleta', 'unidad', 'unidad', 1, 2.00, 200, NULL),
('Frenos de Bicicleta', 'par', 'unidad', 1, 5.00, 500, NULL),
('Caballo de Silla', 'unidad', 'unidad', 1, 500.00, 50000, NULL),
('Burro de Carga', 'unidad', 'unidad', 1, 300.00, 30000, NULL),
('Mula de Carga', 'unidad', 'unidad', 1, 400.00, 40000, NULL),
('Cuatro Venezolano', 'unidad', 'unidad', 1, 25.00, 2500, NULL),
('Guitarra Artesanal', 'unidad', 'unidad', 1, 40.00, 4000, NULL),
('Tambor (Caja)', 'unidad', 'unidad', 1, 30.00, 3000, NULL),
('Maracas (Par)', 'par', 'unidad', 1, 8.00, 800, NULL),
('Flauta de Caña', 'unidad', 'unidad', 1, 3.00, 300, NULL),
('Pintura y Artes Visuales', 'unidad', 'unidad', 1, 15.00, 1500, NULL),
('Agua Purificada', 'L', 'L', 1, 0.14, 14, NULL),

-- Embalaje ecológico
('Vasos de Hoja de Platano', 'unidad', 'unidad', 1, 0.60, 60, NULL),
('Vasos de Bagazo de Caña', 'unidad', 'unidad', 1, 0.80, 80, NULL),
('Vasos de PLA (Maiz)', 'unidad', 'unidad', 1, 1.40, 140, NULL),
('Vasos de Totuma/Calabaza', 'unidad', 'unidad', 1, 0.30, 30, NULL),
('Vasos de Coco', 'unidad', 'unidad', 1, 0.60, 60, NULL),
('Vasos de Barro/Ceramica', 'unidad', 'unidad', 1, 4.00, 400, NULL),
('Platos de Hoja de Platano', 'unidad', 'unidad', 1, 0.60, 60, NULL),
('Platos de Bagazo', 'unidad', 'unidad', 1, 0.80, 80, NULL),
('Platos de Fibra de Bambu', 'unidad', 'unidad', 1, 1.10, 110, NULL),
('Platos de Hoja de Palma', 'unidad', 'unidad', 1, 0.40, 40, NULL),
('Contenedores de Bagazo con Tapa', 'unidad', 'unidad', 1, 1.40, 140, NULL),
('Contenedores de Fibra de Bambu', 'unidad', 'unidad', 1, 1.70, 170, NULL),
('Contenedores de Hoja de Platano', 'unidad', 'unidad', 1, 0.80, 80, NULL),
('Bolsas de Tela de Algodón', 'unidad', 'unidad', 1, 14.00, 1400, NULL),
('Bolsas de Tela de Yute', 'unidad', 'unidad', 1, 8.00, 800, NULL),
('Bolsas de Papel Reciclado', 'unidad', 'unidad', 1, 2.00, 200, NULL),
('Bolsas Biodegradables de Almidon', 'unidad', 'unidad', 1, 3.00, 300, NULL),
('Envoltura de Cera de Abejas', 'unidad', 'unidad', 1, 3.00, 300, NULL),
('Envoltura de Hoja de Platano', 'unidad', 'unidad', 1, 0.15, 15, NULL),
('Envoltura de Papel Encerado', 'unidad', 'unidad', 1, 1.00, 100, NULL),
('Cubiertos de Madera', 'set', 'unidad', 1, 1.00, 100, NULL),
('Cubiertos de Bambu', 'set', 'unidad', 1, 1.00, 100, NULL),
('Pajitas de Caña Natural', 'unidad', 'unidad', 1, 0.15, 15, NULL),
('Pajitas de Papel', 'unidad', 'unidad', 1, 0.28, 28, NULL),

-- Feria Conuquera (cosecha fresca, lácteos, procesados y compuestos con energía real)
('Topocho Fresco', 'kg', 'kg', 1, 0.60, 60, NULL),
('Mapuey Fresco', 'kg', 'kg', 1, 0.80, 80, NULL),
('Name Morado Fresco', 'kg', 'kg', 1, 0.80, 80, NULL),
('Verdolaga Fresca', 'kg', 'kg', 1, 0.40, 40, NULL),
('Pira (Amaranto) Fresca', 'kg', 'kg', 1, 0.70, 70, NULL),
('Rucula Fresca', 'kg', 'kg', 1, 0.40, 40, NULL),
('Col Rizada (Kale) Fresca', 'kg', 'kg', 1, 0.40, 40, NULL),
('Sauco Fresco', 'kg', 'kg', 1, 0.40, 40, NULL),
('Aji Picante Fresco', 'kg', 'kg', 1, 0.90, 90, NULL),
('Aji Dulce Fresco', 'kg', 'kg', 1, 0.90, 90, NULL),
('Toronjil Fresco', 'kg', 'kg', 1, 0.40, 40, NULL),
('Moras Frescas', 'kg', 'kg', 1, 0.80, 80, NULL),
('Leche de Cabra Fresca', 'L', 'L', 1, 1.40, 140, NULL),
('Queso de Cabra Artesanal', 'kg', 'kg', 1, 2.80, 280, NULL),
('Queso de Bufala Artesanal', 'kg', 'kg', 1, 3.30, 330, NULL),
('Ricota Artesanal', 'kg', 'kg', 1, 2.20, 220, NULL),
('Yogurt Natural Artesanal', 'kg', 'kg', 1, 1.10, 110, NULL),
('Dulce de Leche Artesanal', 'kg', 'kg', 1, 2.20, 220, NULL),
('Polen de Abejas', 'kg', 'kg', 1, 1.00, 100, NULL),
('Onoto Natural Fresco', 'kg', 'kg', 1, 0.80, 80, NULL),
('Curcuma Fresca', 'kg', 'kg', 1, 0.80, 80, NULL),
('Jengibre Fresco', 'kg', 'kg', 1, 0.80, 80, NULL),
('Chocolate Artesanal 80%', 'kg', 'kg', 1, 5.60, 560, NULL),
('Chocolate Artesanal 100%', 'kg', 'kg', 1, 6.90, 690, NULL),
('Cacao en Polvo Artesanal', 'kg', 'kg', 1, 5.60, 560, NULL),
('Cafe Molido Artesanal', 'kg', 'kg', 1, 4.20, 420, NULL),
('Casabe Artesanal', 'unidad', 'kg', 0.10, 3.50, 35, NULL),
('Naiboa Artesanal', 'unidad', 'kg', 0.28, 5.50, 154, NULL),
('Catalinas Artesanales', 'unidad', 'kg', 0.088, 5.80, 51, NULL),
('Besito de Coco Artesanal', 'unidad', 'kg', 0.037, 5.00, 19, NULL),
('Cafunga de Barlovento', 'unidad', 'kg', 0.16, 2.90, 46, NULL),
('Pan Artesanal de Masa Madre', 'kg', 'kg', 1, 5.40, 540, NULL),
('Arepa de Auyama Artesanal', 'unidad', 'kg', 0.10, 2.40, 24, NULL),
('Arepa de Platano Artesanal', 'unidad', 'kg', 0.10, 2.30, 23, NULL),
('Torta de Platano Artesanal', 'porcion', 'kg', 0.15, 2.60, 39, NULL),
('Papelon con Limon', 'L', 'L', 1, 1.20, 120, NULL),
('Aguamiel', 'L', 'L', 1, 1.05, 105, NULL),
('Hidromiel (Vino de Miel)', 'L', 'L', 1, 1.50, 150, NULL),
('Cocomiel', 'L', 'L', 1, 0.80, 80, NULL),
('Harina de Yuca Artesanal', 'kg', 'kg', 1, 3.20, 320, NULL),
('Harina de Cambur Artesanal', 'kg', 'kg', 1, 3.30, 330, NULL),
('Jabon Artesanal de Aceite Reciclado', 'unidad', 'kg', 0.09, 2.80, 25, NULL),
('Desodorante Natural Artesanal', 'unidad', 'kg', 0.05, 3.10, 16, NULL),
('Croquetas de Soya Artesanales', 'unidad', 'kg', 0.025, 6.30, 16, NULL),
('Torticas Veganas Artesanales', 'unidad', 'kg', 0.03, 4.70, 14, NULL),
('Chimichurri de Mango Artesanal', 'frasco', 'kg', 0.25, 4.30, 108, NULL);

-- Aplicar la tabla maestra a todos los productos (tanto en __FEDERATION__ como en los nodos)
UPDATE products p
SET unit = cfp.unit,
    base_unit = cfp.base_unit,
    weight_kg = cfp.weight_kg,
    price_per_kg = cfp.price_per_kg,
    price_per_unit = cfp.price_per_unit_cents,
    description = COALESCE(cfp.new_description, p.description),
    updated_at = NOW()
FROM clean_federation_prices cfp
WHERE LOWER(TRIM(p.name)) = LOWER(TRIM(cfp.name));

-- 5. Para cualquier otro producto en __FEDERATION__ que no esté en la lista anterior
--    pero haya quedado multiplicado x100 dos veces (migraciones 192 y 196):
UPDATE products
SET price_per_unit = ROUND(price_per_kg * weight_kg * 100.0)
WHERE node_domain = '__FEDERATION__'
  AND price_per_kg > 0 AND weight_kg > 0
  AND ABS(price_per_unit - ROUND(price_per_kg * weight_kg * 100.0)) >= 1;

UPDATE products
SET price_per_unit = ROUND(price_per_unit / 100.0),
    price_per_kg = CASE WHEN COALESCE(price_per_kg, 0) = 0 THEN ROUND(price_per_unit / 10000.0, 2) ELSE price_per_kg END,
    weight_kg = CASE WHEN COALESCE(weight_kg, 0) = 0 THEN 1 ELSE weight_kg END
WHERE node_domain = '__FEDERATION__'
  AND price_per_unit >= 10000
  AND MOD(price_per_unit::bigint, 10000) = 0
  AND (COALESCE(energy_direct, 0) + COALESCE(energy_human, 0) + COALESCE(energy_inputs, 0) + COALESCE(energy_amortization, 0)) > 0
  AND ABS((price_per_unit / 10000.0) - (COALESCE(energy_direct, 0) + COALESCE(energy_human, 0) + COALESCE(energy_inputs, 0) + COALESCE(energy_amortization, 0))) <= 5
  AND NOT EXISTS (
      SELECT 1 FROM clean_federation_prices cfp WHERE LOWER(TRIM(cfp.name)) = LOWER(TRIM(products.name))
  );

-- Si algún producto compuesto que sí está en uso aún tiene price_per_unit <= 0,
-- recalcularlo desde sus componentes en product_compositions o fijar mínimo energético real
UPDATE products p
SET price_per_unit = GREATEST(100, COALESCE((
    SELECT ROUND(SUM(
        compute_federation_variant_price_cents(
            COALESCE(comp.price_per_unit, 100),
            COALESCE(comp.price_per_kg, 1),
            COALESCE(comp.weight_kg, 1),
            COALESCE(comp.unit, 'unidad'),
            COALESCE(comp.base_unit, 'kg'),
            COALESCE(comp.unit, 'unidad'),
            COALESCE(pc.quantity_needed, 1)
        )
    ))
    FROM product_compositions pc
    JOIN products comp ON comp.id = pc.component_product_id
    WHERE pc.product_id = p.id
), 100))
WHERE COALESCE(p.price_per_unit, 0) <= 0;

-- 6. Propagar de forma estricta todos los precios de __FEDERATION__ hacia las copias en nodos
UPDATE products node_p
SET price_per_unit = fed.price_per_unit,
    price_per_kg   = fed.price_per_kg,
    weight_kg      = fed.weight_kg,
    base_unit      = fed.base_unit,
    unit           = fed.unit,
    description    = fed.description,
    updated_at     = NOW()
FROM products fed
WHERE fed.node_domain = '__FEDERATION__'
  AND node_p.node_domain <> '__FEDERATION__'
  AND (
      (COALESCE(node_p.catalog_key, '') <> '' AND node_p.catalog_key = fed.catalog_key)
      OR (COALESCE(node_p.product_code, '') <> '' AND node_p.product_code = fed.product_code)
      OR LOWER(TRIM(node_p.name)) = LOWER(TRIM(fed.name))
  );

-- 7. Recalcular todos los store_items vinculados a productos desde __FEDERATION__
UPDATE store_items si
SET base_price = compute_federation_variant_price_cents(
        COALESCE(fed.price_per_unit, p.price_per_unit, 0),
        COALESCE(fed.price_per_kg, p.price_per_kg, 0),
        COALESCE(fed.weight_kg, p.weight_kg, 0),
        COALESCE(NULLIF(fed.unit, ''), NULLIF(p.unit, ''), 'unidad'),
        COALESCE(NULLIF(fed.base_unit, ''), NULLIF(p.base_unit, ''), 'kg'),
        COALESCE(NULLIF(si.unit, ''), NULLIF(fed.unit, ''), NULLIF(p.unit, ''), 'unidad'),
        COALESCE(NULLIF(si.quantity_per_unit, 0), 1)
    ),
    price_trueque = compute_federation_variant_price_cents(
        COALESCE(fed.price_per_unit, p.price_per_unit, 0),
        COALESCE(fed.price_per_kg, p.price_per_kg, 0),
        COALESCE(fed.weight_kg, p.weight_kg, 0),
        COALESCE(NULLIF(fed.unit, ''), NULLIF(p.unit, ''), 'unidad'),
        COALESCE(NULLIF(fed.base_unit, ''), NULLIF(p.base_unit, ''), 'kg'),
        COALESCE(NULLIF(si.unit, ''), NULLIF(fed.unit, ''), NULLIF(p.unit, ''), 'unidad'),
        COALESCE(NULLIF(si.quantity_per_unit, 0), 1)
    ) + COALESCE(si.extra_costs, 0),
    final_price = compute_federation_variant_price_cents(
        COALESCE(fed.price_per_unit, p.price_per_unit, 0),
        COALESCE(fed.price_per_kg, p.price_per_kg, 0),
        COALESCE(fed.weight_kg, p.weight_kg, 0),
        COALESCE(NULLIF(fed.unit, ''), NULLIF(p.unit, ''), 'unidad'),
        COALESCE(NULLIF(fed.base_unit, ''), NULLIF(p.base_unit, ''), 'kg'),
        COALESCE(NULLIF(si.unit, ''), NULLIF(fed.unit, ''), NULLIF(p.unit, ''), 'unidad'),
        COALESCE(NULLIF(si.quantity_per_unit, 0), 1)
    ) + COALESCE(si.extra_costs, 0),
    updated_at = NOW()
FROM products p
LEFT JOIN LATERAL (
    SELECT f.price_per_unit, f.price_per_kg, f.unit, f.weight_kg, f.base_unit
    FROM products f
    WHERE f.node_domain = '__FEDERATION__' AND f.is_active = true
      AND (
          (COALESCE(p.catalog_key, '') <> '' AND f.catalog_key = p.catalog_key)
          OR (COALESCE(p.product_code, '') <> '' AND f.product_code = p.product_code)
          OR LOWER(TRIM(f.name)) = LOWER(TRIM(p.name))
      )
    ORDER BY (f.catalog_key = p.catalog_key) DESC
    LIMIT 1
) fed ON true
WHERE si.product_id = p.id;

-- 8. Asegurar visibilidad en POS y vinculación de categorías/ítems con terminales activas
UPDATE store_items SET show_in_pos = true WHERE show_in_pos IS NULL;
UPDATE store_categories SET show_in_pos = true WHERE show_in_pos IS NULL;

-- Si hay un terminal activo con merchant_user_id pero los store_items quedaron con owner_id NULL,
-- asignarlos al dueño principal de la tienda o al merchant_user_id del terminal activo
UPDATE store_items
SET owner_id = COALESCE(
    (SELECT merchant_user_id FROM nfc_terminals WHERE is_active = true AND merchant_user_id IS NOT NULL ORDER BY created_at DESC LIMIT 1),
    (SELECT id FROM users WHERE COALESCE(is_super_admin, false) = true ORDER BY created_at ASC LIMIT 1)
)
WHERE owner_id IS NULL;

-- 9. Unificar los 6 servicios universales de Trabajo entre Mi Tienda y el POS Android
-- Desmarcar los servicios viejos (#90118, #90119, #90121, #90001) como universales
UPDATE products SET is_universal_service = false WHERE COALESCE(is_universal_service, false) = true;

-- Si en store_items se habían materializado filas de los 4 servicios viejos universales, desactivarlas
UPDATE store_items
SET is_active = false
WHERE item_code IN ('90118', '90119', '90121', '90001')
   OR product_name IN ('Jornada Agricola Completa', 'Jornada de Trabajo General', 'Jornal Agricola', 'Trabajo en el Conuco (Hora)');

UPDATE products
SET catalog_key = NULL
WHERE catalog_key IN (
    'svc-work-admin-hora', 'svc-work-admin-jornada',
    'svc-work-tecnico-hora', 'svc-work-tecnico-jornada',
    'svc-work-agricola-hora', 'svc-work-agricola-jornada'
) AND id NOT IN (
    '00000000-0000-4000-8000-0000000900a1',
    '00000000-0000-4000-8000-0000000900a2',
    '00000000-0000-4000-8000-0000000900b1',
    '00000000-0000-4000-8000-0000000900b2',
    '00000000-0000-4000-8000-0000000900c1',
    '00000000-0000-4000-8000-0000000900c2'
);

-- Insertar o actualizar los 6 servicios universales de trabajo bajo la categoría fija 'Trabajo'
INSERT INTO products (
    id, node_domain, name, parent_category, category, subcategory, origin, unit, base_unit, weight_kg,
    description, badge, image_url, price_per_unit, price_per_kg,
    is_approved, is_system, is_allowed, is_active, is_universal_service,
    product_code, item_code, catalog_key, item_type,
    energy_direct, energy_human, energy_inputs, energy_amortization
) VALUES
    ('00000000-0000-4000-8000-0000000900a1', '__FEDERATION__', 'Trabajo sedentario / oficina (1 hora)', 'Servicios', 'Trabajo', 'Oficina y Gestion', 'internal', 'hora', 'hora', 1,
     'Hora de trabajo sedentario, oficina, atencion o gestion administrativa (1.00 TQ/hora). Servicio universal disponible en todas las tiendas y puntos de venta.', 'Universal', '', 100, 1.00,
     true, true, true, true, true, 'SVC-900A1', '900a1', 'svc-work-admin-hora', 'service', 0, 1, 0, 0),
    ('00000000-0000-4000-8000-0000000900a2', '__FEDERATION__', 'Jornada completa — Trabajo sedentario / oficina', 'Servicios', 'Trabajo', 'Oficina y Gestion', 'internal', 'jornada', 'jornada', 1,
     'Jornada completa (8 horas) de trabajo sedentario, oficina, atencion o gestion administrativa (8.00 TQ/jornada). Servicio universal.', 'Universal', '', 800, 8.00,
     true, true, true, true, true, 'SVC-900A2', '900a2', 'svc-work-admin-jornada', 'service', 0, 8, 0, 0),
    ('00000000-0000-4000-8000-0000000900b1', '__FEDERATION__', 'Trabajo profesional / especialista (1 hora)', 'Servicios', 'Trabajo', 'Profesional y Tecnico', 'internal', 'hora', 'hora', 1,
     'Hora de trabajo profesional, tecnico o especialista calificado (1.15 TQ/hora). Servicio universal disponible en todas las tiendas y puntos de venta.', 'Universal', '', 115, 1.15,
     true, true, true, true, true, 'SVC-900T1', '900t1', 'svc-work-tecnico-hora', 'service', 0, 1.15, 0, 0),
    ('00000000-0000-4000-8000-0000000900b2', '__FEDERATION__', 'Jornada completa — Trabajo profesional / especialista', 'Servicios', 'Trabajo', 'Profesional y Tecnico', 'internal', 'jornada', 'jornada', 1,
     'Jornada completa (8 horas) de trabajo profesional, tecnico o especialista calificado (9.20 TQ/jornada). Servicio universal.', 'Universal', '', 920, 9.20,
     true, true, true, true, true, 'SVC-900T2', '900t2', 'svc-work-tecnico-jornada', 'service', 0, 9.2, 0, 0),
    ('00000000-0000-4000-8000-0000000900c1', '__FEDERATION__', 'Trabajo pesado / agrícola (conuco) (1 hora)', 'Servicios', 'Trabajo', 'Trabajo Agricola y Pesado', 'internal', 'hora', 'hora', 1,
     'Hora de trabajo pesado o agricola en el conuco / Mano Vuelta (1.30 TQ/hora). Servicio universal disponible en todas las tiendas y puntos de venta.', 'Universal', '', 130, 1.30,
     true, true, true, true, true, 'SVC-900G1', '900g1', 'svc-work-agricola-hora', 'service', 0, 1.3, 0, 0),
    ('00000000-0000-4000-8000-0000000900c2', '__FEDERATION__', 'Jornada completa — Trabajo pesado / agrícola (conuco)', 'Servicios', 'Trabajo', 'Trabajo Agricola y Pesado', 'internal', 'jornada', 'jornada', 1,
     'Jornada completa (8 horas) de trabajo pesado o agricola en el conuco / Mano Vuelta (10.40 TQ/jornada). Servicio universal.', 'Universal', '', 1040, 10.40,
     true, true, true, true, true, 'SVC-900G2', '900g2', 'svc-work-agricola-jornada', 'service', 0, 10.4, 0, 0)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    parent_category = 'Servicios',
    category = 'Trabajo',
    subcategory = EXCLUDED.subcategory,
    unit = EXCLUDED.unit,
    base_unit = EXCLUDED.base_unit,
    weight_kg = 1,
    description = EXCLUDED.description,
    price_per_unit = EXCLUDED.price_per_unit,
    price_per_kg = EXCLUDED.price_per_kg,
    is_approved = true,
    is_system = true,
    is_allowed = true,
    is_active = true,
    is_universal_service = true,
    item_code = EXCLUDED.item_code,
    catalog_key = EXCLUDED.catalog_key,
    item_type = 'service',
    updated_at = NOW();

-- Asegurar que las categorías de los productos activos en store_items (ej: Insumos Agricolas)
-- y la categoría fija Trabajo existan en store_categories para el dueño de la tienda
INSERT INTO store_categories (node_domain, owner_id, name, show_in_pos)
SELECT DISTINCT si.node_domain, si.owner_id, si.category, true
FROM store_items si
WHERE si.owner_id IS NOT NULL
  AND si.is_active = true
  AND COALESCE(si.category, '') <> ''
ON CONFLICT (owner_id, name) DO UPDATE SET show_in_pos = COALESCE(store_categories.show_in_pos, true);

INSERT INTO store_categories (node_domain, owner_id, name, show_in_pos)
SELECT DISTINCT si.node_domain, si.owner_id, 'Trabajo', true
FROM store_items si
WHERE si.owner_id IS NOT NULL
ON CONFLICT (owner_id, name) DO UPDATE SET show_in_pos = true;

-- Limpiar tablas y funciones auxiliares de migración
DROP TABLE IF EXISTS clean_federation_prices;
DROP FUNCTION IF EXISTS merge_duplicate_product(TEXT, TEXT);
