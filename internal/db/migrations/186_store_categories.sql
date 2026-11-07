-- 186: store_categories — categorías propias de cada dueño de tienda.
-- El dueño crea sus categorías aquí y asigna productos a ellas; el POS
-- las replica automáticamente (agrupa por store_items.category).
CREATE TABLE IF NOT EXISTS store_categories (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    node_domain VARCHAR(255) NOT NULL,
    owner_id    UUID NOT NULL,
    name        VARCHAR(120) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (owner_id, name)
);
CREATE INDEX IF NOT EXISTS idx_store_categories_owner ON store_categories (owner_id, node_domain);
