-- 188: medidas calculables para unidades de empaque — "saco" no es una
-- medida; todo contenedor debe declarar su equivalencia en la unidad base
-- (kg/L/m) para que el POS/tienda pueda dosificar con precio calculado.

-- Saco estándar = 25 kg (fertilizantes, granos, harinas por convención)
UPDATE products SET weight_kg = 25
WHERE LOWER(unit) IN ('saco', 'saco de cemento', 'bulto')
  AND COALESCE(weight_kg, 0) = 0;

-- Otros empaques frecuentes → equivalencia en la unidad base
UPDATE products SET weight_kg = 1 WHERE LOWER(unit) IN ('kg', 'kilo', 'kilogramo') AND COALESCE(weight_kg, 0) = 0;
UPDATE products SET weight_kg = 0.5 WHERE LOWER(unit) IN ('media', 'medio saco', 'medio bulto') AND COALESCE(weight_kg, 0) = 0;
UPDATE products SET weight_kg = 1 WHERE LOWER(unit) IN ('litro', 'l', 'botella', 'frasco') AND COALESCE(weight_kg, 0) = 0 AND COALESCE(base_unit, 'kg') = 'L';
UPDATE products SET weight_kg = 1 WHERE LOWER(unit) IN ('unidad', 'pieza', 'paquete') AND COALESCE(weight_kg, 0) = 0;

-- Extraer "saco de X kg" de la descripción cuando existe el número real —
-- el texto informativo queda, pero el número va al campo calculable.
-- (Solo donde weight_kg siga en 0 tras los defaults.)
UPDATE products
SET weight_kg = CAST(substring(description FROM 'saco de ~?(\d+(?:\.\d+)?) ?kg') AS numeric)
WHERE LOWER(unit) = 'saco'
  AND COALESCE(weight_kg, 0) IN (0, 25)
  AND description ~ 'saco de ~?(\d+(?:\.\d+)?) ?kg';
