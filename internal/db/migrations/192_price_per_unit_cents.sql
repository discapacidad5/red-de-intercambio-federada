-- 192: NORMALIZACIÓN TOTAL — price_per_unit en CENTAVOS (fmtTQ divide /100).
-- Datos verificados: TODA la tabla está en escala TQ (1.00, 54, 300, 1319).
-- price_per_kg se mantiene en TQ (los displays lo usan directo).

-- A) Contenedores con medida: precio = price_per_kg(TQ) × weight_kg × 100 centavos
UPDATE products
SET price_per_unit = ROUND(price_per_kg * weight_kg * 100)
WHERE weight_kg > 0 AND price_per_kg > 0
  AND LOWER(unit) NOT IN ('kg','kilo','kilogramo','g','gramo','l','litro','ml','m','metro','unidad','hora','jornada','sesion','viaje');

-- B) Todos los demás productos: TQ → centavos (×100). Excluye los del paso A.
UPDATE products
SET price_per_unit = ROUND(price_per_unit * 100)
WHERE price_per_unit > 0
  AND NOT (
    weight_kg > 0 AND price_per_kg > 0
    AND LOWER(unit) NOT IN ('kg','kilo','kilogramo','g','gramo','l','litro','ml','m','metro','unidad','hora','jornada','sesion','viaje')
  );
