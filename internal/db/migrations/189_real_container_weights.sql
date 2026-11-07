-- 189: pesos reales por producto — cada contenedor declara su
-- equivalencia en la unidad base para dosificación con precio calculado.

-- Sacos de insumos agrícolas: 25 kg estándar (fertilizante/tierra)
UPDATE products SET weight_kg = 25, base_unit = 'kg'
WHERE name IN ('Abonos Organicos', 'Tierra Fertil y Sustratos')
  AND COALESCE(weight_kg, 0) IN (0, 25);

-- Carbón vegetal: saco ~20 kg (sacos de carbón artesanal LatAm)
UPDATE products SET weight_kg = 20, base_unit = 'kg'
WHERE name = 'Carbon Vegetal' AND COALESCE(weight_kg, 0) = 0;

-- Harina de maíz: el nombre ya declara el saco de 50 kg
UPDATE products SET weight_kg = 50, base_unit = 'kg'
WHERE name ILIKE 'Harina de maiz%50%kg%' AND COALESCE(weight_kg, 0) = 0;

-- Huevos por docena: ~0.65 kg la docena (30 huevos/kg aprox)
UPDATE products SET weight_kg = 0.65, base_unit = 'unidad', quantity_per_unit = 12
WHERE LOWER(unit) = 'docena' AND name ILIKE '%huevos%' AND COALESCE(weight_kg, 0) = 0;

-- Botiquín: infusiones caja ~0.05 kg, vendas ~0.2 kg, apósitos ~0.15 kg
UPDATE products SET weight_kg = 0.05, base_unit = 'kg' WHERE name = 'Infusiones Naturales Mezcladas' AND COALESCE(weight_kg, 0) = 0;
UPDATE products SET weight_kg = 0.20, base_unit = 'kg' WHERE name = 'Vendas y Gasas (Paquete)' AND COALESCE(weight_kg, 0) = 0;
UPDATE products SET weight_kg = 0.15, base_unit = 'kg' WHERE name = 'Apositos y Tiritas (Caja)' AND COALESCE(weight_kg, 0) = 0;

-- Paquetes de componentes electrónicos: unidades, no peso — count units
UPDATE products SET base_unit = 'unidad', quantity_per_unit = 10
WHERE name IN ('Resistencias (Paquete 10)', 'Capacitores (Paquete 10)', 'Fusibles (Paquete 10)')
  AND COALESCE(quantity_per_unit, 0) IN (0, 1);
UPDATE products SET base_unit = 'unidad', quantity_per_unit = 1
WHERE name IN ('Conectores (Paquete)', 'Vendas y Gasas (Paquete)')
  AND COALESCE(quantity_per_unit, 0) IN (0, 1);
