-- 197: un producto tiene UN solo precio — el del catálogo padre.
-- Si el producto de la Federación cambia de precio, todas las copias
-- locales (nodos que lo incorporaron por product_code) se actualizan.
-- Los store_items ya derivan su precio del padre al leer, así que el
-- cambio llega a todas las tiendas automáticamente.
CREATE OR REPLACE FUNCTION propagate_parent_price() RETURNS trigger AS $$
BEGIN
    IF NEW.price_per_unit IS DISTINCT FROM OLD.price_per_unit
       OR NEW.price_per_kg IS DISTINCT FROM OLD.price_per_kg
       OR NEW.weight_kg     IS DISTINCT FROM OLD.weight_kg THEN
        UPDATE products
        SET price_per_unit = NEW.price_per_unit,
            price_per_kg   = NEW.price_per_kg,
            weight_kg      = NEW.weight_kg,
            base_unit      = NEW.base_unit
        WHERE product_code = NEW.product_code
          AND node_domain  <> NEW.node_domain
          AND id           <> NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_propagate_parent_price ON products;
CREATE TRIGGER trg_propagate_parent_price
AFTER UPDATE OF price_per_unit, price_per_kg, weight_kg, base_unit ON products
FOR EACH ROW EXECUTE FUNCTION propagate_parent_price();
