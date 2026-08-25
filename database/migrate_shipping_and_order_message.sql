USE lensify;

-- Stores an optional instruction from the customer and keeps the admin-managed
-- free-shipping threshold in the existing settings table.
ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_message VARCHAR(1000) NULL AFTER delivery_address;

INSERT IGNORE INTO site_settings (setting_key, setting_value)
VALUES ('free_shipping_threshold', '2000');
