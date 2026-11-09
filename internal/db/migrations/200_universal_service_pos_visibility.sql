-- 200: Visibilidad en el POS de los 6 servicios universales de Trabajo, por dueño.
-- Los servicios universales no son filas propias de store_items de cada tienda
-- (se agregan en vivo), así que su casilla "En POS" se guarda aquí.
CREATE TABLE IF NOT EXISTS store_universal_service_prefs (
    owner_id    UUID NOT NULL,
    product_id  UUID NOT NULL,
    show_in_pos BOOLEAN NOT NULL DEFAULT true,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (owner_id, product_id)
);

