-- 187: visibilidad de categorías en POS + multi-categoría por item
-- store_categories.show_in_pos: el dueño decide qué categorías aparecen
-- en su punto de venta (incluye categorías traídas del catálogo).
ALTER TABLE store_categories ADD COLUMN IF NOT EXISTS show_in_pos BOOLEAN NOT NULL DEFAULT true;
-- store_items.categories: varias categorías por producto (la columna
-- 'category' queda como la principal para compatibilidad).
ALTER TABLE store_items ADD COLUMN IF NOT EXISTS categories TEXT[] NOT NULL DEFAULT '{}';
