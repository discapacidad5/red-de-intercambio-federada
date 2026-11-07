-- 193: normalizar TODOS los montos a centavos (convención: guardar centavos,
-- mostrar /100). Los items heredan del producto padre; los productos de
-- trabajo/hora también se pasan a centavos.

-- A) store_items ligados a producto: precio desde el padre (ya en centavos
--    tras la 192) respetando la unidad de venta del item
UPDATE store_items si
SET price_trueque = ROUND(
        CASE
          -- misma unidad de venta que el padre: precio del padre directo
          WHEN LOWER(si.unit) = LOWER(p.unit) THEN p.price_per_unit
          -- unidad dosificada (saco→kg/g/etc): ppk(TQ) × quantity_per_unit × 100
          ELSE COALESCE(p.price_per_kg, 0) * COALESCE(NULLIF(si.quantity_per_unit,0),1) * 100
        END),
    final_price   = ROUND(
        CASE
          WHEN LOWER(si.unit) = LOWER(p.unit) THEN p.price_per_unit
          ELSE COALESCE(p.price_per_kg, 0) * COALESCE(NULLIF(si.quantity_per_unit,0),1) * 100
        END + COALESCE(si.extra_costs, 0)),
    base_price    = p.price_per_unit
FROM products p
WHERE p.id = si.product_id
  AND (si.price_trueque < 10  -- valores en TQ-scale (2.25) → centavos
       OR si.price_trueque IS DISTINCT FROM
          ROUND(COALESCE(p.price_per_kg,0) * COALESCE(NULLIF(si.quantity_per_unit,0),1) * 100));

-- B) items propios (sin producto padre) con precio en TQ-scale → centavos.
--    Heurística: precio < 100 asumido TQ (2.25 → 225); ya en centavos no tocar.
UPDATE store_items
SET price_trueque = ROUND(price_trueque * 100),
    final_price   = ROUND((COALESCE(final_price, price_trueque) * 100) + COALESCE(extra_costs, 0))
WHERE product_id IS NULL AND price_trueque > 0 AND price_trueque < 50;

-- C) productos de trabajo (hora/jornada) — tarifas TQ → centavos
UPDATE products SET price_per_unit = ROUND(price_per_unit * 100)
WHERE (COALESCE(is_universal_service, false) = true OR LOWER(unit) IN ('hora','jornada'))
  AND price_per_unit > 0 AND price_per_unit < 50;
