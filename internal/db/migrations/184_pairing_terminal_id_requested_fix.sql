-- Migracion 184: Corregir columna terminal_id_requested faltante
--
-- La migracion 099_pairing_terminal_id.sql intentaba agregar esta columna
-- con un DO block condicional, pero como se ejecuta ANTES de la migracion
-- 125 (que crea la tabla), siempre resultaba no-op. Por eso el endpoint
-- /api/nfc/terminal/pair/initiate fallaba con:
--   ERROR: column "terminal_id_requested" of relation
--   "terminal_pairing_requests" does not exist (SQLSTATE 42703)
--
-- Esta migracion se ejecuta despues de 125, cuando la tabla ya existe.

ALTER TABLE terminal_pairing_requests
    ADD COLUMN IF NOT EXISTS terminal_id_requested TEXT;
