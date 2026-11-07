-- 193: store_items a centavos — mismos datos verificados (price_trueque=2.25 TQ).
-- Todos los montos del item ×100; para items del catálogo el valor correcto
-- sale del producto padre (ya centavos tras la 192).

-- A) Items ligados a producto: recalcular desde el padre (centavos)
UPDATE store_items si
SET price_trueque = ROUND(
        CASE WHEN LOWER(si.unit) = LOWER(p.unit)
             THEN p.price_per_unit
             ELSE COALESCE(p.price_per_kg,0) * COALESCE(NULLIF(si.quantity_per_unit,0),1) * 100
        END),
    base_price = p.price_per_unit
FROM products p
WHERE p.id = si.product_id;

UPDATE store_items si
SET final_price = ROUND(price_trueque + COALESCE(extra_costs,0) * 100)
WHERE product_id IS NOT NULL
  AND (COALESCE(final_price,0) <= 0 OR final_price < price_trueque);

-- B) Items propios (sin padre): todo TQ → centavos
UPDATE store_items
SET price_trueque = ROUND(price_trueque * 100),
    final_price   = ROUND(COALESCE(final_price,0) * 100),
    base_price    = ROUND(COALESCE(base_price,0) * 100),
    extra_costs   = ROUND(COALESCE(extra_costs,0) * 100)
WHERE product_id IS NULL;
