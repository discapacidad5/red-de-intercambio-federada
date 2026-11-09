-- Migración 201: Auditoría energética completa, eliminación de duplicados y reconstrucción
-- coherente de precios del catálogo de la Federación (__FEDERATION__).
--
-- Correcciones principales:
-- 1. Eliminación de productos duplicados que describían lo mismo con precios contradictorios:
--    - 'Compost Maduro Artesanal' (0.40 TQ/kg) -> unificado en 'Abonos Organicos' (2.25 TQ / saco 25 kg = 0.09 TQ/kg)
--    - 'Mantequilla y Queso' (10.00 TQ/kg) -> unificado en 'Lacteos Artesanales' (12.00 TQ/kg)
--    - Servicios de trabajo antiguos duplicados ('Jornal Agricola', 'Jornada Agricola Completa',
--      'Trabajo en el Conuco (Hora)', 'Jornada de Trabajo General', 'Jornada de Trabajo Tecnico')
--      -> unificados en los 6 servicios universales oficiales (#900a1..#900g2).
-- 2. Jerarquía energética real de los Huevos (docena = 0.65 kg):
--    - 'Huevos de Gallinas Felices (Pastoreo)': 3.00 TQ/docena (4.62 TQ/kg) — pastoreo libre en conuco
--      (forraje, insectos y lombrices con energía solar directa, sin pienso industrial ni galpón).
--    - 'Huevos Criollos (Semilibres)': 5.00 TQ/docena (7.69 TQ/kg) — patio/corral + grano local.
--    - 'Huevos Comerciales (Jaula)': 9.00 TQ/docena (13.85 TQ/kg) — 100% alimento concentrado industrial
--      (cultivo intensivo, secado, molienda, transporte = 4.50 TQ) + electricidad de galpón (1.50 TQ)
--      + pasivo ambiental y sanitario del confinamiento en jaula (3.00 TQ).
-- 3. Coherencia termodinámica en lácteos, derivados de cacao/café, harinas, panadería, miel/fermentados,
--    dulces tradicionales, conservas, cosecha fresca de conuco, higiene natural y calzado artesanal:
--    ningún producto elaborado cuesta menos que la suma de sus materias primas + cocción/procesamiento + trabajo.

DO $$
DECLARE
    v_abonos_id UUID;
    v_lacteos_id UUID;
    v_conuco_hora_id UUID := '00000000-0000-0000-0000-0000000900d1';
    v_conuco_jornada_id UUID := '00000000-0000-0000-0000-0000000900d2';
    v_general_jornada_id UUID := '00000000-0000-0000-0000-0000000900a2';
    v_tecnico_jornada_id UUID := '00000000-0000-0000-0000-0000000900e2';
    r RECORD;
BEGIN
    SELECT id INTO v_abonos_id FROM products WHERE node_domain = '__FEDERATION__' AND name = 'Abonos Organicos' LIMIT 1;
    SELECT id INTO v_lacteos_id FROM products WHERE node_domain = '__FEDERATION__' AND name = 'Lacteos Artesanales' LIMIT 1;

    -- 1. Re-apuntar referencias de duplicados antes de eliminarlos
    FOR r IN
        SELECT id, name FROM products
        WHERE name IN (
            'Compost Maduro Artesanal',
            'Mantequilla y Queso',
            'Jornal Agricola',
            'Jornada Agricola Completa',
            'Trabajo en el Conuco (Hora)',
            'Jornada de Trabajo General',
            'Jornada de Trabajo Tecnico',
            'Huevos Frescos'
        )
    LOOP
        DECLARE
            v_target_id UUID := NULL;
        BEGIN
            IF r.name = 'Compost Maduro Artesanal' THEN
                v_target_id := v_abonos_id;
            ELSIF r.name = 'Mantequilla y Queso' THEN
                v_target_id := v_lacteos_id;
            ELSIF r.name IN ('Jornal Agricola', 'Trabajo en el Conuco (Hora)') THEN
                v_target_id := v_conuco_hora_id;
            ELSIF r.name = 'Jornada Agricola Completa' THEN
                v_target_id := v_conuco_jornada_id;
            ELSIF r.name = 'Jornada de Trabajo General' THEN
                v_target_id := v_general_jornada_id;
            ELSIF r.name = 'Jornada de Trabajo Tecnico' THEN
                v_target_id := v_tecnico_jornada_id;
            END IF;

            IF v_target_id IS NOT NULL AND v_target_id <> r.id THEN
                -- Si el dueño ya tiene el producto destino en su tienda, eliminar el duplicado en store_items
                DELETE FROM store_items si
                WHERE si.catalog_product_id = r.id
                  AND EXISTS (
                      SELECT 1 FROM store_items si2
                      WHERE si2.owner_id = si.owner_id AND si2.catalog_product_id = v_target_id
                  );

                UPDATE store_items SET catalog_product_id = v_target_id WHERE catalog_product_id = r.id;

                -- Re-apuntar composiciones si no existe ya el componente destino
                DELETE FROM product_compositions pc
                WHERE pc.component_product_id = r.id
                  AND EXISTS (
                      SELECT 1 FROM product_compositions pc2
                      WHERE pc2.parent_product_id = pc.parent_product_id
                        AND pc2.component_product_id = v_target_id
                  );
                UPDATE product_compositions SET component_product_id = v_target_id WHERE component_product_id = r.id;
            END IF;

            DELETE FROM product_compositions WHERE parent_product_id = r.id OR component_product_id = r.id;
            DELETE FROM store_items WHERE catalog_product_id = r.id;
            DELETE FROM products WHERE id = r.id;
        END;
    END LOOP;
END $$;

-- 2. Tabla temporal con los valores auditados de precio, unidad, peso y descripción
CREATE TEMP TABLE tmp_catalog_audit (
    name TEXT PRIMARY KEY,
    unit TEXT,
    base_unit TEXT,
    weight_kg DOUBLE PRECISION,
    price_per_kg DOUBLE PRECISION,
    price_per_unit_tq DOUBLE PRECISION,
    description TEXT
) ON COMMIT DROP;

INSERT INTO tmp_catalog_audit (name, unit, base_unit, weight_kg, price_per_kg, price_per_unit_tq, description) VALUES
-- Huevos (docena = 0.65 kg)
('Huevos de Gallinas Felices (Pastoreo)', 'docena', 'kg', 0.65, 4.62, 3.00,
 'Huevos de gallinas felices en pastoreo rotativo libre en conuco. Las aves se alimentan de forraje verde, insectos y lombrices (energia solar directa) con minimo suplemento de grano local (~0.4 kg maiz = 1.20 TQ) + manejo humano (1.80 TQ). Sin gasto de alimento concentrado industrial ni electricidad de galpon. Energia total: ~16.6 MJ/kg = 4.62 kWh/kg. Una docena pesa ~0.65 kg: 4.62 x 0.65 = 3.00 TQ/docena.'),
('Huevos Criollos (Semilibres)', 'docena', 'kg', 0.65, 7.69, 5.00,
 'Huevos de gallinas criollas semilibres en patio o corral. Alimentacion mixta: pastoreo parcial en suelo + suplemento diario de maiz/granos criollos (~1.0 kg grano = 3.50 TQ) + cuidado y recoleccion (1.50 TQ). Energia total: ~27.7 MJ/kg = 7.69 kWh/kg. Una docena pesa ~0.65 kg: 7.69 x 0.65 = 5.00 TQ/docena.'),
('Huevos Comerciales (Jaula)', 'docena', 'kg', 0.65, 13.85, 9.00,
 'Huevos de gallinas confinadas en jaula industrial. Requiere 100% alimento concentrado ponedora comprado (cultivo industrial de soya/maiz con agroquimicos, secado, molienda, peletizado y transporte: ~2 kg pienso/kg huevo = 4.50 TQ) + electricidad continua de galpon (ventilacion, iluminacion artificial, bombeo = 1.50 TQ) + pasivo ambiental y sanitario del encierro (estres animal, antibioticos, contaminacion por estiercol concentrado y amortizacion de jaulas = 3.00 TQ). Energia total: ~50 MJ/kg = 13.85 kWh/kg. Una docena pesa ~0.65 kg: 13.85 x 0.65 = 9.00 TQ/docena.'),

-- Lácteos y derivados (coherentes con Leche Fresca = 2.00 TQ/L y Leche de Cabra = 2.20 TQ/L)
('Leche Fresca', 'litro', 'L', 1.0, 2.00, 2.00,
 'Leche fresca de vaca de pastoreo. Energia: ~7.2 MJ/L = 2.00 kWh/L (forraje + ordeno manual + enfriamiento/pasteurizacion). Fuente: Ecoinvent, JRC, USDA.'),
('Leche de Cabra Fresca', 'L', 'L', 1.0, 2.20, 2.20,
 'Leche de cabra fresca de pastoreo. Energia: ~7.9 MJ/L = 2.20 kWh/L (pastoreo + suplemento + ordeno manual e higiene). Fuente: FAO. Documentado en Feria Conuquera (Silio Sanchez, Lechivita).'),
('Bebidas Lacteas', 'litro', 'L', 1.0, 3.00, 3.00,
 'Yogurt liquido batido, kefir de leche, chicha con leche fresca, suero cremoso. Energia: 1 L leche fresca (2.00 TQ) + fermentacion/batido y enfriamiento (1.00 TQ) = 3.00 TQ/L (~10.8 MJ/L).'),
('Yogurt Natural Artesanal', 'kg', 'kg', 1.0, 3.50, 3.50,
 'Yogurt natural artesanal sin conservantes. Requiere 1.1 L de leche fresca por kg (2.20 TQ) + calentamiento a 85C e incubacion termica (0.60 TQ) + cultivo lactico y trabajo (0.70 TQ) = 3.50 TQ/kg (~12.6 MJ/kg). Fuente: Agribalyse. Documentado en Feria Conuquera (Lechivita).'),
('Ricota Artesanal', 'kg', 'kg', 1.0, 5.50, 5.50,
 'Ricota (requeson) artesanal obtenida por recoccion del suero lacteo dulce enriquecido con leche fresca. Energia: suero + leche (2.50 TQ) + coccion a 90C durante 1h (1.80 TQ) + escurrido y trabajo (1.20 TQ) = 5.50 TQ/kg (~19.8 MJ/kg). Documentado en Feria Conuquera.'),
('Dulce de Leche Artesanal', 'kg', 'kg', 1.0, 11.00, 11.00,
 'Dulce de leche (arequipe/manjar) artesanal. Para 1 kg se concentran ~2.5 L de leche fresca (2.5 x 2.00 = 5.00 TQ) + 0.5 kg de azucar/papelon (0.5 x 5.00 = 2.50 TQ) + 2.5 horas de coccion por evaporacion continua (2.00 TQ) + 1.5h de paleteo manual (1.50 TQ) = 11.00 TQ/kg (~39.6 MJ/kg). Documentado en Feria Conuquera (Lechivita).'),
('Lacteos Artesanales', 'kg', 'kg', 1.0, 12.00, 12.00,
 'Queso blanco duro/semiduro, queso de mano, guayanes, cuajada y mantequilla artesanal. Requiere ~5 L de leche fresca por kg (5 x 2.00 = 10.00 TQ) + cuajo/sal + prensado, coccion o batido y trabajo artesanal (2.00 TQ) = 12.00 TQ/kg (~43 MJ/kg). Fuente: Agribalyse, FAO.'),
('Queso de Cabra Artesanal', 'kg', 'kg', 1.0, 13.00, 13.00,
 'Queso artesanal de leche de cabra. Requiere ~5 L de leche de cabra fresca por kg (5 x 2.20 = 11.00 TQ) + cuajo natural, sal, prensado y maduracion (2.00 TQ) = 13.00 TQ/kg (~46.8 MJ/kg). Fuente: LCA productos lacteos. Documentado en Feria Conuquera (Silio Sanchez, Lechivita).'),
('Queso de Bufala Artesanal', 'kg', 'kg', 1.0, 13.00, 13.00,
 'Queso artesanal de leche de bufala (mozzarella/blanco). Requiere ~4.8 L de leche de bufala por kg (10.50 TQ) + cuajo, hilado en agua caliente y trabajo artesanal (2.50 TQ) = 13.00 TQ/kg (~46.8 MJ/kg). Fuente: LCA productos lacteos. Documentado en Feria Conuquera (Lechivita).'),

-- Harinas, panadería y masas (coherentes con granos = 3-4 TQ/kg y tubérculos = 1.5-2 TQ/kg)
('Harinas Integrales', 'kg', 'kg', 1.0, 5.00, 5.00,
 'Harina de maiz precocida/pilada, trigo integral, avena o legumbres. Energia: 1.15 kg de grano seco (3.50 TQ) + limpieza, secado y molienda artesanal (1.50 TQ) = 5.00 TQ/kg (~18 MJ/kg). Fuente: Agribalyse, Piringer & Steinberg 2006.'),
('Harina de Yuca Artesanal', 'kg', 'kg', 1.0, 6.00, 6.00,
 'Harina de yuca deshidratada y molida sin gluten. Rendimiento 40%: requiere 2.5 kg de yuca fresca por kg de harina (2.5 x 2.00 = 5.00 TQ) + pelado, secado solar/horno y molienda fina (1.00 TQ) = 6.00 TQ/kg. Fuente: CIAT. Documentado en Feria Conuquera (Luis Angel Leisiaga).'),
('Harina de Cambur Artesanal', 'kg', 'kg', 1.0, 7.00, 7.00,
 'Harina de cambur/platano verde rica en almidon resistente. Rendimiento 25%: requiere 4 kg de cambur verde fresco por kg de harina (4 x 1.20 = 4.80 TQ) + pelado manual, rebanado, deshidratado y molienda (2.20 TQ) = 7.00 TQ/kg. Documentado en Feria Conuquera (Luis Angel Leisiaga).'),
('Panaderia y Masas Caseras', 'kg', 'kg', 1.0, 6.00, 6.00,
 'Pan de maiz, trigo integral, arepas, cachapas, bollos, empanadas. Energia: ~21.6 MJ/kg = 6.00 kWh/kg (harina integral 4.00 TQ + amasado y horneado artesanal 2.00 TQ). Fuente: JRC Europa, Agribalyse.'),
('Pan Artesanal de Masa Madre', 'kg', 'kg', 1.0, 6.50, 6.50,
 'Pan artesanal de masa madre con fermentacion lenta de 24h. Por kg de pan: 0.75 kg harina integral (3.75 TQ) + horneado artesanal y amasado manual (2.75 TQ) = 6.50 TQ/kg (~23.4 MJ/kg). Documentado en Feria Conuquera (Flor de Tilo).'),

-- Cacao, chocolate y café
('Cacao, Chocolate y Cafe', 'kg', 'kg', 1.0, 10.00, 10.00,
 'Cacao en grano fermentado y secado al sol de Barlovento/Chuao y cafe pergamino lavado. Energia: ~36 MJ/kg = 10.00 kWh/kg (cosecha + fermentacion en cajones + secado solar + seleccion). Fuente: FOB UK, Agribalyse.'),
('Cafe Molido Artesanal', 'kg', 'kg', 1.0, 9.00, 9.00,
 'Cafe arabica/criollo tostado y molido artesanalmente. Requiere 1.25 kg de cafe verde seco por merma de tueste (6.50 TQ) + torrefaccion controlada y molienda (2.50 TQ) = 9.00 TQ/kg (~32.4 MJ/kg). Fuente: Agribalyse. Documentado en Feria Conuquera.'),
('Cacao en Polvo Artesanal', 'kg', 'kg', 1.0, 9.50, 9.50,
 'Cacao puro en polvo artesanal. Elaborado a partir de grano fermentado tostado, descascarillado, prensado y pulverizado: 9.50 TQ/kg (~34.2 MJ/kg). Fuente: LCA cacao procesado. Documentado en Feria Conuquera (Cacao Siborori).'),
('Chocolate Artesanal 80%', 'kg', 'kg', 1.0, 12.50, 12.50,
 'Chocolate artesanal 80% cacao de Barlovento/Paria. Elaboracion por kg: 0.85 kg cacao fermentado/tostado (8.50 TQ) + 0.20 kg papelon/azucar (1.00 TQ) + descascarillado, molienda en piedra/conchado y templado (3.00 TQ) = 12.50 TQ/kg (~45 MJ/kg). Documentado en Feria Conuquera (Cacao Siborori).'),
('Chocolate Artesanal 100%', 'kg', 'kg', 1.0, 13.00, 13.00,
 'Chocolate artesanal 100% cacao (pasta/licor de cacao puro sin azucar). Elaboracion por kg: 1.20 kg cacao en grano seco por merma de cascarilla (9.60 TQ) + tostado, descascarillado manual y molienda fina en caliente (3.40 TQ) = 13.00 TQ/kg (~46.8 MJ/kg). Documentado en Feria Conuquera (Cacao Siborori).'),

-- Miel, polen y bebidas naturales/fermentadas
('Polen de Abejas', 'kg', 'kg', 1.0, 12.00, 12.00,
 'Polen apicola granulado recolectado en trampas de piquera y deshidratado a baja temperatura. Una colmena produce solo 2-4 kg/ano: manejo apicola + recoleccion diaria + secado suave y limpieza manual = 12.00 TQ/kg (~43.2 MJ/kg). Fuente: FAO (apicultura). Documentado en Feria Conuquera (Lechivita).'),
('Zumos y Jugos Naturales', 'litro', 'L', 1.0, 1.50, 1.50,
 'Jugos de frutas naturales exprimidos (naranja, limon, mango, guayaba, parchita, pina). Requiere ~1.5 kg de fruta fresca + extraccion y filtrado = 1.50 TQ/L (~5.4 MJ/L).'),
('Refrescos Efervescentes', 'litro', 'L', 1.0, 2.00, 2.00,
 'Bebidas efervescentes artesanales: ginger beer, limonada gasificada natural, tepache. Fruta/jengibre + papelon + fermentacion carbonica = 2.00 TQ/L (~7.2 MJ/L).'),
('Papelon con Limon', 'L', 'L', 1.0, 1.60, 1.60,
 'Guarapo de papelon con limon (1 L). Elaborado con 200g de papelon (1.00 TQ) + limones frescos (0.30 TQ) + agua filtrada y exprimido (0.30 TQ) = 1.60 TQ/L. Documentado en Feria Conuquera.'),
('Aguamiel', 'L', 'L', 1.0, 1.50, 1.50,
 'Aguamiel refrescante/fermentada ligera (1 L). Elaborada con 150g de miel pura de abejas (1.05 TQ) + agua purificada y acondicionamiento (0.45 TQ) = 1.50 TQ/L. Documentado en Feria Conuquera (Lechivita).'),
('Cocomiel', 'L', 'L', 1.0, 3.00, 3.00,
 'Bebida tonica y fermentada de leche/agua de coco con miel pura de abejas (1 L). Ingredientes: 200g miel pura (1.40 TQ) + coco fresco procesado (0.90 TQ) + coccion/extraccion y trabajo (0.70 TQ) = 3.00 TQ/L. Documentado en Feria Conuquera (Lechivita).'),
('Hidromiel (Vino de Miel)', 'L', 'L', 1.0, 3.50, 3.50,
 'Hidromiel artesanal (vino de miel fermentado y madurado 4 semanas). Por litro: 300g de miel pura de abejas (2.10 TQ) + levadura, sanitizacion, trasiegos y envasado (1.40 TQ) = 3.50 TQ/L. Documentado en Feria Conuquera (Lechivita).'),

-- Dulces, conservas, salsas y gastronomía artesanal
('Dulces y Conservas Tradicionales', 'frasco', 'kg', 0.50, 8.00, 4.00,
 'Dulce de lechosa, cabello de angel, jalea de guayaba, conservas de coco, bocadillo. Frasco de 0.5 kg: fruta seleccionada (1.00 TQ) + papelon/azucar (1.50 TQ) + coccion en paila 1.5h (1.00 TQ) + esterilizado y envasado (0.50 TQ) = 4.00 TQ/frasco (8.00 TQ/kg). Fuente: Agribalyse.'),
('Encurtidos y Salsas', 'frasco', 'kg', 0.50, 7.00, 3.50,
 'Encurtidos de vegetales, salsa de tomate artesanal, picante en conserva, guasacaca. Frasco de 0.5 kg: hortalizas y especias (1.20 TQ) + vinagre/aceite (1.30 TQ) + coccion y esterilizado (1.00 TQ) = 3.50 TQ/frasco (7.00 TQ/kg). Fuente: Agribalyse.'),
('Chimichurri de Mango Artesanal', 'frasco', 'kg', 0.25, 7.20, 1.80,
 'Chimichurri artesanal de mango, aji dulce, ajo, cilantro, vinagre y aceite (frasco 250g). Ingredientes + coccion y envasado: 7.20 TQ/kg -> 1.80 TQ/frasco (250g). Documentado en Feria Conuquera (Luis Angel Leisiaga).'),
('Casabe Artesanal', 'unidad', 'kg', 0.10, 6.00, 0.60,
 'Casabe artesanal de yuca amarga (torta ~100g). Lote: 2.5 kg yuca fresca (5.00 TQ) -> 1 kg casabe (10 tortas de 100g). Pelado, rallado, prensado en sebucan y tendido en budare (1.00 TQ) = 6.00 TQ/kg -> 0.60 TQ/unidad (100g). Documentado en Feria Conuquera (Flor de Tilo).'),
('Naiboa Artesanal', 'unidad', 'kg', 0.28, 8.00, 2.24,
 'Naiboa artesanal (280g). Dos tortas de casabe (1.20 TQ) rellenas con melado de papelon (0.35 TQ), queso blanco rallado (0.45 TQ) y anis, horneadas (0.24 TQ) = 2.24 TQ/unidad (8.00 TQ/kg). Documentado en Feria Conuquera (Flor de Tilo).'),
('Catalinas Artesanales', 'unidad', 'kg', 0.088, 8.00, 0.70,
 'Catalina o paledonia artesanal (~88g). Elaborada con harina integral, melado de papelon especiado, mantequilla/huevo y horneado: 8.00 TQ/kg -> 0.70 TQ/unidad (88g). Documentado en Feria Conuquera (Flor de Tilo).'),
('Besito de Coco Artesanal', 'unidad', 'kg', 0.037, 7.50, 0.28,
 'Besito de coco artesanal (~37g). Coco rallado fresco, papelon en melado, harina, huevo y horneado: 7.50 TQ/kg -> 0.28 TQ/unidad (37g). Documentado en Feria Conuquera.'),
('Cafunga de Barlovento', 'unidad', 'kg', 0.16, 5.50, 0.88,
 'Cafunga de Barlovento (~160g). Dulce afrovenezolano de cambur maduro, coco rallado, papelon y anis envuelto en hoja de platano y asado: 5.50 TQ/kg -> 0.88 TQ/unidad (160g). Documentado en Feria Conuquera.'),
('Arepa de Auyama Artesanal', 'unidad', 'kg', 0.10, 5.00, 0.50,
 'Arepa de auyama y maiz asada en budare (~100g). Masa de maiz/harina integral con auyama cocida + asado: 5.00 TQ/kg -> 0.50 TQ/unidad (100g). Documentado en Feria Conuquera.'),
('Arepa de Platano Artesanal', 'unidad', 'kg', 0.10, 5.00, 0.50,
 'Arepa de platano verde/pintón asada en budare (~100g). Platano cocido y molido + masa de maiz + asado: 5.00 TQ/kg -> 0.50 TQ/unidad (100g). Documentado en Feria Conuquera.'),
('Torta de Platano Artesanal', 'porcion', 'kg', 0.15, 7.00, 1.05,
 'Torta artesanal de platano maduro con papelon, queso y especias (porcion ~150g). Energia de ingredientes + horneado: 7.00 TQ/kg -> 1.05 TQ/porcion (150g). Documentado en Feria Conuquera.'),
('Croquetas de Soya Artesanales', 'unidad', 'kg', 0.025, 8.00, 0.20,
 'Croquetas de soya y especias (~25g). Remojo, molienda, amasado con harina integral y coccion: 8.00 TQ/kg -> 0.20 TQ/unidad (25g). Documentado en Feria Conuquera (Luis Angel Leisiaga).'),
('Torticas Veganas Artesanales', 'unidad', 'kg', 0.03, 7.00, 0.21,
 'Torticas veganas de vegetales y granos (~30g). Preparacion y coccion en plancha: 7.00 TQ/kg -> 0.21 TQ/unidad (30g). Documentado en Feria Conuquera (Luis Angel Leisiaga).'),

-- Cosecha fresca de conuco (Feria Conuquera)
('Topocho Fresco', 'kg', 'kg', 1.0, 1.20, 1.20,
 'Topocho fresco de conuco (Musa x paradisiaca). Energia: cultivo + cosecha manual y acarreo ~4.3 MJ/kg = 1.20 kWh/kg. Fuente: FAO. Documentado en Feria Conuquera.'),
('Mapuey Fresco', 'kg', 'kg', 1.0, 1.50, 1.50,
 'Mapuey (Dioscorea trifida) fresco de conuco. Tuberculo nativo americano. Energia: siembra + desmalezado + cosecha manual ~5.4 MJ/kg = 1.50 kWh/kg. Fuente: estudios LCA tuberculos andinos. Documentado en Feria Conuquera (Unidad Docovaca).'),
('Name Morado Fresco', 'kg', 'kg', 1.0, 1.50, 1.50,
 'Name morado fresco de conuco. Variedad de Dioscorea rica en minerales y antioxidantes. Energia: cultivo + excavacion manual ~5.4 MJ/kg = 1.50 kWh/kg. Fuente: estudios LCA tuberculos. Documentado en Feria Conuquera (Unidad Docovaca).'),
('Verdolaga Fresca', 'kg', 'kg', 1.0, 1.20, 1.20,
 'Verdolaga (Portulaca oleracea) fresca. Hoja verde comestible rica en omega-3. Energia: cultivo + recoleccion y lavado ~4.3 MJ/kg = 1.20 kWh/kg. Fuente: Agribalyse (hojas verdes). Documentado en Feria Conuquera (Unidad Docovaca).'),
('Pira (Amaranto) Fresca', 'kg', 'kg', 1.0, 1.20, 1.20,
 'Pira o amaranto (Amaranthus) fresco (Yerba Caracas). Hoja verde altamente nutritiva. Energia: cultivo + cosecha manual ~4.3 MJ/kg = 1.20 kWh/kg. Fuente: FAO. Documentado en Feria Conuquera (Unidad Docovaca).'),
('Rucula Fresca', 'kg', 'kg', 1.0, 1.20, 1.20,
 'Rucula (Eruca vesicaria) fresca. Hoja de ensalada con sabor ligeramente picante. Energia: cultivo + corte y lavado ~4.3 MJ/kg = 1.20 kWh/kg. Fuente: Agribalyse. Documentado en Feria Conuquera (Alfivegetales, El Junquito).'),
('Col Rizada (Kale) Fresca', 'kg', 'kg', 1.0, 1.20, 1.20,
 'Col rizada o kale (Brassica oleracea var. acephala) fresca. Energia: cultivo organico + cosecha manual ~4.3 MJ/kg = 1.20 kWh/kg. Fuente: Agribalyse. Documentado en Feria Conuquera (Alfivegetales, El Junquito).'),
('Sauco Fresco', 'kg', 'kg', 1.0, 1.20, 1.20,
 'Sauco (Sambucus) fresco. Hoja y flor medicinal/comestible. Energia: recoleccion selectiva y limpieza ~4.3 MJ/kg = 1.20 kWh/kg. Fuente: Agribalyse. Documentado en Feria Conuquera.'),
('Toronjil Fresco', 'kg', 'kg', 1.0, 1.20, 1.20,
 'Toronjil (Melissa officinalis) fresco. Hierba aromatica medicinal. Energia: cultivo + corte manual ~4.3 MJ/kg = 1.20 kWh/kg. Fuente: Agribalyse. Documentado en Feria Conuquera.'),
('Aji Picante Fresco', 'kg', 'kg', 1.0, 1.80, 1.80,
 'Aji picante fresco (Capsicum). Variedades criollas de conuco. Energia: semillero + trasplante + cosecha manual fruto por fruto ~6.5 MJ/kg = 1.80 kWh/kg. Fuente: Agribalyse. Documentado en Feria Conuquera (Alfivegetales).'),
('Aji Dulce Fresco', 'kg', 'kg', 1.0, 1.80, 1.80,
 'Aji dulce fresco (Capsicum chinense). Base del sofrito venezolano. Energia: semillero + cultivo + cosecha manual fruto por fruto ~6.5 MJ/kg = 1.80 kWh/kg. Fuente: Agribalyse. Documentado en Feria Conuquera.'),
('Moras Frescas', 'kg', 'kg', 1.0, 2.20, 2.20,
 'Moras (Rubus) frescas de altura. Energia: manejo de espaldera + recoleccion manual delicada ~7.9 MJ/kg = 2.20 kWh/kg. Fuente: Agribalyse (frutas rojas). Documentado en Feria Conuquera (Alfivegetales, El Junquito).'),
('Onoto Natural Fresco', 'kg', 'kg', 1.0, 1.80, 1.80,
 'Semilla de onoto natural (Bixa orellana) cosechada y desgranada de las capsulas. Energia: cosecha + desgranado manual y secado al sol ~6.5 MJ/kg = 1.80 kWh/kg. Fuente: Agribalyse. Documentado en Feria Conuquera.'),
('Curcuma Fresca', 'kg', 'kg', 1.0, 1.80, 1.80,
 'Rizoma de curcuma (Curcuma longa) fresca. Energia: ciclo de 9 meses + desenterrado manual y lavado ~6.5 MJ/kg = 1.80 kWh/kg. Fuente: Agribalyse. Documentado en Feria Conuquera (SanaTe).'),
('Jengibre Fresco', 'kg', 'kg', 1.0, 1.80, 1.80,
 'Rizoma de jengibre (Zingiber officinale) fresco. Energia: ciclo largo + cosecha manual y limpieza ~6.5 MJ/kg = 1.80 kWh/kg. Fuente: Agribalyse. Documentado en Feria Conuquera (SanaTe).'),

-- Higiene natural y calzado artesanal
('Jabon Artesanal de Aceite Reciclado', 'unidad', 'kg', 0.09, 8.00, 0.72,
 'Jabon ecologico saponificado en frio y curado 4 semanas (barra 90g). Energia de filtrado de aceite, alcali (NaOH), moldes y trabajo artesanal: 8.00 TQ/kg -> 0.72 TQ/unidad (90g). Documentado en Feria Conuquera (Territorio K-ribe).'),
('Desodorante Natural Artesanal', 'unidad', 'kg', 0.05, 16.00, 0.80,
 'Desodorante natural en barra/crema (50g) a base de aceite de coco, cera de abejas, bicarbonato, almidon y aceites esenciales: 16.00 TQ/kg -> 0.80 TQ/unidad (50g). Documentado en Feria Conuquera (Territorio K-ribe).'),
('Calzado de Cuero', 'par', 'par', 0.65, 33.85, 22.00,
 'Sandalias, zapatos o botines de cuero artesanal (~0.65 kg/par). Energia: 0.45 kg cuero curtido (10.80 TQ) + suela de caucho/cuero e hilo encerado (3.20 TQ) + corte, aparado y costura manual 8h (8.00 TQ) = 22.00 TQ/par.'),
('Calzado Textil', 'par', 'par', 0.40, 25.00, 10.00,
 'Alpargatas, zapatillas de tela o calzado textil artesanal (~0.40 kg/par). Energia: 0.15 kg capellada tejida de algodon/pabilo (6.00 TQ) + suela de cocuiza/caucho (1.50 TQ) + tejido y armado manual 2.5h (2.50 TQ) = 10.00 TQ/par.'),

-- Abonos y canasta básica
('Abonos Organicos', 'saco', 'kg', 25.0, 0.09, 2.25,
 'Compost maduro, humus de lombriz, estiercol curado, bokashi, gallinaza. Energia: ~0.3 MJ/kg = 0.09 kWh/kg (proceso de descomposicion controlada). Un saco de 25 kg = 2.25 TQ. Fuente: Nigeria organic fertilizer study, Italy on-farm compost LCA.'),
('Canasta Basica Familiar Semanal', 'canasta', 'canasta', 10.5, 2.86, 30.00,
 'Canasta semanal para familia de 4-5 personas (10.5 kg). Contenido: 3kg granos basicos (maiz, frijol, arroz) = 9 TQ, 2kg verduras frescas = 4 TQ, 1kg frutas de temporada = 2 TQ, 0.5kg carne de pollo = 2.5 TQ, 1L leche fresca = 2 TQ, 0.5L aceite vegetal = 3 TQ, 0.5kg panela/azucar = 2.5 TQ, 1 docena huevos de gallinas felices = 3 TQ, 100g especias = 1 TQ. Energia total: ~29 TQ. Precio redondeado: 30 TQ.');

-- 3. Aplicar los valores auditados a products
UPDATE products p
SET unit           = a.unit,
    base_unit      = a.base_unit,
    weight_kg      = a.weight_kg,
    price_per_kg   = a.price_per_kg,
    price_per_unit = ROUND(a.price_per_unit_tq * 100)::BIGINT,
    energy_inputs  = a.price_per_unit_tq,
    description    = a.description
FROM tmp_catalog_audit a
WHERE p.name = a.name
  AND (p.node_domain = '__FEDERATION__' OR p.is_system = TRUE);

-- 4. Sincronizar store_items vinculados a productos del catálogo federado
UPDATE store_items si
SET price_tq    = ROUND(p.price_per_unit)::BIGINT,
    unit        = p.unit,
    description = p.description
FROM products p
WHERE si.catalog_product_id = p.id
  AND p.node_domain = '__FEDERATION__';

