-- 190: sincronizar price_per_unit con el precio por unidad base × peso.
-- El catálogo guarda precio/kg y los kg del contenedor — el precio por
-- saco/caja debe ser price_per_kg × weight_kg, no un valor distinto.
UPDATE products
SET price_per_unit = price_per_kg * weight_kg
WHERE weight_kg > 0 AND price_per_kg > 0
  AND LOWER(unit) NOT IN ('kg','kilo','kilogramo','g','gramo','l','litro','ml','m','unidad','hora','jornada')
  AND ABS(COALESCE(price_per_unit,0) - (price_per_kg * weight_kg)) > 0.001;
