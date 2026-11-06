-- Migracion 185: Fundacion de ajustes del punto de venta
--
-- 1. admin_pin_hash en nfc_terminals: clave de Ajustes del POS, distinta del
--    shift_pin_hash (que es para abrir/cerrar el punto). El dueno la configura
--    en el panel web igual que el PIN de turno.
-- 2. show_in_pos en store_items: el dueno decide que productos aparecen en el
--    POS (optimiza la descarga en conexiones lentas). Default true = no rompe
--    nada existente.
-- 3. pos_accounts: cuenta provisional del terminal. Los cobros caen aqui
--    mientras el punto esta abierto; al cerrar el turno se liquida el total
--    a destination_account_id (cuenta del dueno: persona u organizacion).
-- 4. node_config.workday_hours + work_multipliers: base para el calculo
--    correcto de jornadas (horas configurables por nodo + multiplicador por
--    tipo de trabajo: normal / oficina / agricola).

ALTER TABLE nfc_terminals ADD COLUMN IF NOT EXISTS admin_pin_hash TEXT;
COMMENT ON COLUMN nfc_terminals.admin_pin_hash IS
  'bcrypt del PIN de Ajustes del POS (distinto del PIN de turno). Lo configura el dueno del terminal en el panel web.';

ALTER TABLE store_items ADD COLUMN IF NOT EXISTS show_in_pos BOOLEAN NOT NULL DEFAULT true;
COMMENT ON COLUMN store_items.show_in_pos IS
  'Si el item aparece en el catalogo del punto de venta. El dueno lo activa/desactiva en su tienda.';

CREATE TABLE IF NOT EXISTS pos_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    node_domain TEXT NOT NULL,
    terminal_id TEXT NOT NULL UNIQUE,
    -- Cuenta destino del dueno del punto (usuario u organizacion).
    -- Aqui se liquida el total al cerrar el turno.
    destination_account_id UUID,
    destination_is_org BOOLEAN NOT NULL DEFAULT false,
    -- Saldo provisional acumulado durante el turno abierto (centavos TQ).
    provisional_balance BIGINT NOT NULL DEFAULT 0,
    -- Turno abierto asociado (UUID del shift activo, NULL si cerrado)
    open_shift_id TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_pos_accounts_terminal ON pos_accounts(terminal_id);

ALTER TABLE node_config ADD COLUMN IF NOT EXISTS workday_hours INT NOT NULL DEFAULT 8;
ALTER TABLE node_config ADD COLUMN IF NOT EXISTS work_multipliers JSONB NOT NULL DEFAULT
  '{"normal": 1.0, "oficina": 1.0, "agricola": 1.0}'::jsonb;
COMMENT ON COLUMN node_config.workday_hours IS
  'Horas que componen una jornada de trabajo completa en este nodo (ej: 8 u 5). El POS calcula jornada completa = precio_hora * workday_hours.';
COMMENT ON COLUMN node_config.work_multipliers IS
  'Multiplicadores por tipo de trabajo para el precio base por hora: {"normal": x, "oficina": x, "agricola": x}.';
