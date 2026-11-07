-- 195: eliminar productos duplicados — el catálogo tenía "Abonos
-- Organicos" dos veces (una se actualizó a centavos, la otra quedó en
-- TQ). Se conserva la fila con el precio más alto (centavos = correcto).
DELETE FROM products p1
USING products p2
WHERE p1.name = p2.name
  AND p1.node_domain = p2.node_domain
  AND p1.id < p2.id  -- conserva la de id mayor (la actualizada)
  AND p1.price_per_unit <= p2.price_per_unit;
