-- 192: price_per_unit está en CENTAVOS (fmtTQ divide /100 en la UI) —
-- la migración 190 lo puso en TQ (2.25 mostraba "0,02"). Ahora: precio
-- por unidad = price_per_kg(TQ) × weight_kg × 100 (centavos).
UPDATE products
SET price_per_unit = ROUND(price_per_kg * weight_kg * 100)
WHERE weight_kg > 0 AND price_per_kg > 0
  AND LOWER(unit) NOT IN ('hora','jornada','unidad');
