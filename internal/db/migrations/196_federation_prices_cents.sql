-- 196: el catálogo __FEDERATION__ también a centavos — mismas reglas
-- verificadas en los datos reales del nodo.

-- A) Productos con medida calculable (saco etc.): ppk(TQ) × weight × 100
UPDATE products SET price_per_unit = ROUND(price_per_kg * weight_kg * 100)
WHERE node_domain = '__FEDERATION__'
  AND weight_kg > 0 AND price_per_kg > 0
  AND price_per_unit <> ROUND(price_per_kg * weight_kg * 100);

-- B) Trabajo/hora/jornada/sesión: valores <50 están en TQ → ×100;
--    ≥50 ya son centavos (Trabajo Conuco=100 → se conserva)
UPDATE products SET price_per_unit = ROUND(price_per_unit * 100)
WHERE node_domain = '__FEDERATION__'
  AND price_per_unit > 0 AND price_per_unit < 50
  AND LOWER(unit) IN ('hora','jornada','sesion','viaje')
  AND NOT (weight_kg > 0 AND price_per_kg > 0);

-- C) El resto del catálogo fed (kg/unidad/contenedores sin peso): TQ → ×100
UPDATE products SET price_per_unit = ROUND(price_per_unit * 100)
WHERE node_domain = '__FEDERATION__'
  AND price_per_unit > 0
  AND LOWER(unit) NOT IN ('hora','jornada','sesion','viaje')
  AND NOT (weight_kg > 0 AND price_per_kg > 0);
