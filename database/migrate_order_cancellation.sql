USE lensify;

-- Run this once on existing installations. It keeps a clear audit trail for
-- customer and administrator cancellations.
ALTER TABLE orders ADD COLUMN IF NOT EXISTS cancellation_reason VARCHAR(1000) NULL AFTER order_status;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS cancelled_by INT UNSIGNED NULL AFTER cancellation_reason;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS cancelled_at DATETIME NULL AFTER cancelled_by;
