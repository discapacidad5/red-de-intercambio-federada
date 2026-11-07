-- 194: correcciones sobre valores REALES verificados en producción.

-- A) Los Abonos que quedaron en TQ (duplicado sin actualizar): centavos
UPDATE products SET price_per_unit = ROUND(price_per_kg * weight_kg * 100)
WHERE name = 'Abonos Organicos' AND price_per_unit < 20;

-- B) Trabajo en el Conuco: estaba en 100 centavos (=1.00 TQ/hora) y el
--    ×100 lo llevó a 10000 (=100 TQ). Tarifa correcta: 100 centavos/hora.
UPDATE products SET price_per_unit = 100
WHERE name ILIKE '%Trabajo en el Conuco%' AND LOWER(unit) = 'hora'
  AND price_per_unit > 1000;

-- C) store_items del Conuco con el mismo desajuste
UPDATE store_items SET
    price_trueque = 100,
    final_price   = ROUND(100 + COALESCE(extra_costs,0))
WHERE product_name ILIKE '%Trabajo en el Conuco%' AND price_trueque > 1000;
