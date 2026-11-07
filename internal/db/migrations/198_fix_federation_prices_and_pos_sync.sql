-- Migración 198: Fuente única de precios en __FEDERATION__, cálculo exacto de
-- variantes por unidad (saco, kg, g, L, ml, etc.), publicación de productos
-- compuestos/locales en __FEDERATION__, y sincronización de tienda con POS.

-- 0. Reemplazar el índice único global idx_products_catalog_key por un índice
--    compuesto no restrictivo (node_domain, catalog_key) para que tanto
--    __FEDERATION__ como las copias en los nodos puedan compartir catalog_key
--    sin violar unicidad (SQLSTATE 23505).
DROP INDEX IF EXISTS idx_products_catalog_key;
CREATE INDEX IF NOT EXISTS idx_products_catalog_key
  ON products (node_domain, catalog_key)
  WHERE catalog_key IS NOT NULL AND catalog_key <> '';

-- 1. Función SQL inmutable para calcular el precio en CENTAVOS de cualquier
--    variante de presentación a partir del producto maestro en __FEDERATION__.
CREATE OR REPLACE FUNCTION compute_federation_variant_price_cents(
    fed_price_per_unit DOUBLE PRECISION,
    fed_price_per_kg   DOUBLE PRECISION,
    fed_weight_kg      DOUBLE PRECISION,
    fed_unit           TEXT,
    fed_base_unit      TEXT,
    sell_unit          TEXT,
    sell_qty           DOUBLE PRECISION
) RETURNS DOUBLE PRECISION
LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
    ppu_cents       DOUBLE PRECISION := COALESCE(fed_price_per_unit, 0);
    ppk_tq          DOUBLE PRECISION := COALESCE(fed_price_per_kg, 0);
    w_kg            DOUBLE PRECISION := COALESCE(fed_weight_kg, 0);
    fu              TEXT := LOWER(BTRIM(COALESCE(NULLIF(fed_unit, ''), 'unidad')));
    su              TEXT := LOWER(BTRIM(COALESCE(NULLIF(sell_unit, ''), fu)));
    bu              TEXT := LOWER(BTRIM(COALESCE(NULLIF(fed_base_unit, ''), 'kg')));
    qty             DOUBLE PRECISION := CASE WHEN COALESCE(sell_qty, 0) <= 0 THEN 1.0 ELSE sell_qty END;
    base_unit_cents DOUBLE PRECISION := 0;
    factor_to_base  DOUBLE PRECISION := 1.0;
BEGIN
    -- Normalizar ppu_cents si quedó en escala TQ (con decimales o < 50)
    IF ppu_cents > 0 AND (ppu_cents <> TRUNC(ppu_cents) OR ppu_cents < 50) THEN
        ppu_cents := ROUND(ppu_cents * 100.0);
    END IF;

    -- Si tiene peso y precio por kg, el precio de la presentación federada es ppk * weight * 100
    IF ppk_tq > 0 AND ppk_tq < 100 AND w_kg > 0 THEN
        ppu_cents := ROUND(ppk_tq * w_kg * 100.0);
    END IF;

    -- Precio en centavos por 1 unidad base (ej. 1 kg o 1 L)
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

    -- Misma unidad que la presentación de la Federación
    IF su = fu THEN
        IF w_kg > 1 AND ABS(qty - w_kg) < 0.001 AND su IN ('saco', 'bulto', 'paquete', 'frasco', 'botella', 'canasta') THEN
            RETURN ROUND(ppu_cents);
        END IF;
        RETURN ROUND(ppu_cents * qty);
    END IF;

    -- Conversión entre unidades mediante divisiones/multiplicaciones exactas
    CASE su
        WHEN 'saco', 'bulto' THEN
            factor_to_base := CASE WHEN w_kg > 0 THEN w_kg ELSE 25.0 END;
            IF w_kg > 1 AND ABS(qty - w_kg) < 0.001 THEN
                qty := 1.0;
            END IF;
        WHEN 'quintal' THEN
            factor_to_base := 46.0;
        WHEN 'arroba' THEN
            factor_to_base := 11.5;
        WHEN 'kg', 'kilo', 'kilogramo', 'kilogramos', 'l', 'litro', 'litros', 'm', 'metro', 'metros' THEN
            factor_to_base := 1.0;
        WHEN 'g', 'gr', 'gramo', 'gramos', 'ml', 'mililitro', 'mililitros', 'cc', 'mm', 'milimetro', 'milimetros' THEN
            IF qty >= 1.0 THEN
                factor_to_base := 1.0 / 1000.0;
            ELSE
                factor_to_base := 1.0;
            END IF;
        WHEN 'mg', 'miligramo', 'miligramos' THEN
            IF qty >= 1.0 THEN
                factor_to_base := 1.0 / 1000000.0;
            ELSE
                factor_to_base := 1.0;
            END IF;
        WHEN 'cm', 'centimetro', 'centimetros', 'centímetro' THEN
            IF qty >= 1.0 THEN
                factor_to_base := 1.0 / 100.0;
            ELSE
                factor_to_base := 1.0;
            END IF;
        WHEN 'lb', 'libra', 'libras' THEN
            IF qty >= 1.0 OR ABS(qty - 0.4536) > 0.001 THEN
                factor_to_base := 0.45359237;
            ELSE
                factor_to_base := 1.0;
            END IF;
        WHEN 'oz', 'onza', 'onzas' THEN
            IF qty >= 1.0 OR ABS(qty - 0.02835) > 0.001 THEN
                factor_to_base := 0.0283495;
            ELSE
                factor_to_base := 1.0;
            END IF;
        WHEN 'galon', 'galón' THEN
            IF qty >= 1.0 OR ABS(qty - 3.78541) > 0.001 THEN
                factor_to_base := 3.78541;
            ELSE
                factor_to_base := 1.0;
            END IF;
        WHEN 'pulgada', 'pulgadas', 'in' THEN
            IF qty >= 1.0 OR ABS(qty - 0.0254) > 0.001 THEN
                factor_to_base := 0.0254;
            ELSE
                factor_to_base := 1.0;
            END IF;
        WHEN 'pie', 'pies', 'ft' THEN
            IF qty >= 1.0 OR ABS(qty - 0.3048) > 0.001 THEN
                factor_to_base := 0.3048;
            ELSE
                factor_to_base := 1.0;
            END IF;
        WHEN 'docena' THEN
            factor_to_base := CASE WHEN fu = 'unidad' THEN 12.0 ELSE 1.0 END;
        WHEN 'media docena' THEN
            factor_to_base := CASE WHEN fu = 'docena' THEN 0.5 ELSE 6.0 END;
        WHEN 'par' THEN
            factor_to_base := CASE WHEN fu = 'docena' THEN (2.0 / 12.0) ELSE 2.0 END;
        WHEN 'unidad', 'und' THEN
            factor_to_base := CASE WHEN fu = 'docena' THEN (1.0 / 12.0) ELSE 1.0 END;
        ELSE
            factor_to_base := 1.0;
    END CASE;

    IF base_unit_cents > 0 THEN
        RETURN ROUND(base_unit_cents * factor_to_base * qty);
    END IF;
    RETURN ROUND(ppu_cents * factor_to_base * qty);
END;
$$;

-- Sobrecarga compatible si se invoca con (price_per_unit, price_per_kg, unit, weight_kg, base_unit, sell_unit, sell_qty)
CREATE OR REPLACE FUNCTION compute_federation_variant_price_cents(
    fed_price_per_unit DOUBLE PRECISION,
    fed_price_per_kg   DOUBLE PRECISION,
    fed_unit           TEXT,
    fed_weight_kg      DOUBLE PRECISION,
    fed_base_unit      TEXT,
    sell_unit          TEXT,
    sell_qty           DOUBLE PRECISION
) RETURNS DOUBLE PRECISION
LANGUAGE sql IMMUTABLE AS $$
    SELECT compute_federation_variant_price_cents($1, $2, $4, $3, $5, $6, $7);
$$;

-- 2. Asegurar que todos los productos tengan catalog_key poblado
UPDATE products
SET catalog_key = 'fed-' || TRIM(BOTH '-' FROM REGEXP_REPLACE(
    LOWER(TRANSLATE(name, 'áéíóúüñÁÉÍÓÚÜÑ', 'aeiouunAEIOUUN')),
    '[^a-z0-9]+', '-', 'g'
))
WHERE COALESCE(catalog_key, '') = '';

-- 3. Normalizar price_per_kg (en TQ/unidad base) y price_per_unit (en CENTAVOS)
--    en todos los productos, empezando por __FEDERATION__.
UPDATE products
SET price_per_kg = price_per_kg / 100.0
WHERE price_per_kg >= 100
  AND weight_kg > 0
  AND price_per_unit > 0
  AND ABS((price_per_kg * weight_kg) - price_per_unit) < 1;

UPDATE products
SET price_per_unit = ROUND(price_per_kg * weight_kg * 100.0)
WHERE price_per_kg > 0
  AND price_per_kg < 100
  AND weight_kg > 0
  AND ABS(COALESCE(price_per_unit, 0) - ROUND(price_per_kg * weight_kg * 100.0)) >= 1;

UPDATE products
SET price_per_unit = ROUND(price_per_unit * 100.0)
WHERE price_per_unit > 0
  AND (price_per_unit <> TRUNC(price_per_unit) OR price_per_unit < 50);

-- 4. Publicar en __FEDERATION__ cualquier producto local o compuesto que aún
--    no exista en __FEDERATION__, para que la Federación sea la suma de todos
--    los productos y fuente única de verdad.
INSERT INTO products (
    node_domain, name, description, parent_category, category, subcategory,
    unit, price_per_unit, price_per_kg, weight_kg, base_unit, origin, badge,
    image_url, image_thumb_url, product_code, source_node, source_product_id,
    catalog_key, item_type, is_composite, is_approved, is_system, is_active, is_hidden
)
SELECT DISTINCT ON (LOWER(p.name))
    '__FEDERATION__', p.name, p.description, p.parent_category, p.category, p.subcategory,
    p.unit, p.price_per_unit, p.price_per_kg, p.weight_kg, p.base_unit, COALESCE(p.origin, 'internal'), p.badge,
    p.image_url, p.image_thumb_url, p.product_code, p.node_domain, p.id,
    p.catalog_key,
    CASE WHEN COALESCE(p.is_composite, false) = true THEN 'composite' ELSE COALESCE(NULLIF(p.item_type, ''), 'base_product') END,
    COALESCE(p.is_composite, false), true, true, true, false
FROM products p
WHERE p.node_domain <> '__FEDERATION__'
  AND COALESCE(p.is_hidden, false) = false
  AND NOT EXISTS (
      SELECT 1 FROM products f
      WHERE f.node_domain = '__FEDERATION__'
        AND (
            (NULLIF(p.catalog_key, '') IS NOT NULL AND f.catalog_key = p.catalog_key)
            OR (NULLIF(p.product_code, '') IS NOT NULL AND f.product_code = p.product_code)
            OR LOWER(f.name) = LOWER(p.name)
        )
  )
ORDER BY LOWER(p.name), p.is_approved DESC, p.created_at DESC;

-- 5. Publicar también en __FEDERATION__ los productos compuestos creados en
--    store_items que tenían product_id IS NULL y enlazarlos a __FEDERATION__.
DO $$
DECLARE
    r RECORD;
    v_fed_id UUID;
    v_slug TEXT;
BEGIN
    FOR r IN
        SELECT id, node_domain, product_name, COALESCE(description, extra_description, '') AS descr,
               COALESCE(parent_category, '') AS pcat, COALESCE(category, '') AS cat,
               COALESCE(subcategory, '') AS subcat, COALESCE(unit, 'unidad') AS u,
               GREATEST(COALESCE(final_price, 0), COALESCE(price_trueque, 0), COALESCE(base_price, 0)) AS price_cents
        FROM store_items
        WHERE product_id IS NULL AND is_active = true AND COALESCE(product_name, '') <> ''
    LOOP
        v_slug := 'fed-' || TRIM(BOTH '-' FROM REGEXP_REPLACE(
            LOWER(TRANSLATE(r.product_name, 'áéíóúüñÁÉÍÓÚÜÑ', 'aeiouunAEIOUUN')),
            '[^a-z0-9]+', '-', 'g'
        ));
        IF r.price_cents > 0 AND (r.price_cents <> TRUNC(r.price_cents) OR r.price_cents < 50) THEN
            r.price_cents := ROUND(r.price_cents * 100.0);
        END IF;

        SELECT id INTO v_fed_id
        FROM products
        WHERE node_domain = '__FEDERATION__'
          AND (catalog_key = v_slug OR LOWER(name) = LOWER(r.product_name))
        LIMIT 1;

        IF v_fed_id IS NULL THEN
            INSERT INTO products (
                node_domain, name, description, parent_category, category, subcategory,
                unit, price_per_unit, origin, catalog_key, item_type,
                is_composite, is_approved, is_system, is_active, is_hidden
            ) VALUES (
                '__FEDERATION__', r.product_name, r.descr, r.pcat, r.cat, r.subcat,
                r.u, r.price_cents, 'internal', v_slug, 'composite',
                true, true, true, true, false
            ) RETURNING id INTO v_fed_id;
        END IF;

        UPDATE store_items SET product_id = v_fed_id WHERE id = r.id;
    END LOOP;
END $$;

-- 6. Sincronizar precios de __FEDERATION__ hacia todas las copias en nodos
UPDATE products p
SET price_per_unit = f.price_per_unit,
    price_per_kg   = CASE WHEN COALESCE(f.price_per_kg, 0) > 0 THEN f.price_per_kg ELSE p.price_per_kg END,
    weight_kg      = CASE WHEN COALESCE(f.weight_kg, 0) > 0 THEN f.weight_kg ELSE p.weight_kg END,
    base_unit      = COALESCE(NULLIF(f.base_unit, ''), p.base_unit),
    catalog_key    = COALESCE(NULLIF(f.catalog_key, ''), p.catalog_key)
FROM products f
WHERE p.node_domain <> '__FEDERATION__'
  AND f.node_domain = '__FEDERATION__'
  AND (
      (NULLIF(p.catalog_key, '') IS NOT NULL AND f.catalog_key = p.catalog_key)
      OR (NULLIF(p.product_code, '') IS NOT NULL AND f.product_code = p.product_code)
      OR LOWER(f.name) = LOWER(p.name)
  );

-- 7. Actualizar precios cacheados en store_items usando la función de variantes federadas
UPDATE store_items si
SET base_price    = compute_federation_variant_price_cents(
                        COALESCE(src.price_per_unit, p.price_per_unit, 0),
                        COALESCE(src.price_per_kg, p.price_per_kg, 0),
                        COALESCE(src.weight_kg, p.weight_kg, 0),
                        COALESCE(src.unit, p.unit, 'unidad'),
                        COALESCE(src.base_unit, p.base_unit, 'kg'),
                        si.unit,
                        si.quantity_per_unit
                    ),
    price_trueque = compute_federation_variant_price_cents(
                        COALESCE(src.price_per_unit, p.price_per_unit, 0),
                        COALESCE(src.price_per_kg, p.price_per_kg, 0),
                        COALESCE(src.weight_kg, p.weight_kg, 0),
                        COALESCE(src.unit, p.unit, 'unidad'),
                        COALESCE(src.base_unit, p.base_unit, 'kg'),
                        si.unit,
                        si.quantity_per_unit
                    ),
    final_price   = compute_federation_variant_price_cents(
                        COALESCE(src.price_per_unit, p.price_per_unit, 0),
                        COALESCE(src.price_per_kg, p.price_per_kg, 0),
                        COALESCE(src.weight_kg, p.weight_kg, 0),
                        COALESCE(src.unit, p.unit, 'unidad'),
                        COALESCE(src.base_unit, p.base_unit, 'kg'),
                        si.unit,
                        si.quantity_per_unit
                    ) + COALESCE(si.extra_costs, 0)
FROM products p
LEFT JOIN LATERAL (
    SELECT f.price_per_unit, f.price_per_kg, f.weight_kg, f.unit, f.base_unit
    FROM products f
    WHERE f.node_domain = '__FEDERATION__'
      AND (
          (NULLIF(p.catalog_key, '') IS NOT NULL AND f.catalog_key = p.catalog_key)
          OR (NULLIF(p.product_code, '') IS NOT NULL AND f.product_code = p.product_code)
          OR LOWER(f.name) = LOWER(p.name)
      )
    ORDER BY
      CASE
        WHEN NULLIF(p.catalog_key, '') IS NOT NULL AND f.catalog_key = p.catalog_key THEN 1
        WHEN NULLIF(p.product_code, '') IS NOT NULL AND f.product_code = p.product_code THEN 2
        ELSE 3
      END
    LIMIT 1
) src ON true
WHERE si.product_id = p.id;

-- 8. Alinear owner_id cuando el usuario que creó categorías en store_categories
--    es distinto al admin semilla usado en el backfill de la migración 188.
DO $$
DECLARE
    v_cat_owner UUID;
BEGIN
    SELECT owner_id INTO v_cat_owner
    FROM store_categories
    WHERE owner_id IS NOT NULL
    GROUP BY owner_id
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    IF v_cat_owner IS NOT NULL THEN
        UPDATE store_items
        SET owner_id = v_cat_owner
        WHERE owner_id IS DISTINCT FROM v_cat_owner
          AND (
              owner_id IS NULL
              OR NOT EXISTS (SELECT 1 FROM store_categories sc WHERE sc.owner_id = store_items.owner_id)
          );
    END IF;
END $$;

