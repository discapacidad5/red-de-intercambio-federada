-- 191: reparar store_items con owner_id NULL — quedaban sin dueño por el
-- bug de GetUserID ignorado; el catálogo del POS los excluía.
-- Se asignan al usuario más antiguo del nodo (el admin/dueño de la tienda).
UPDATE store_items
SET owner_id = (SELECT id FROM users ORDER BY created_at ASC LIMIT 1)
WHERE owner_id IS NULL;
