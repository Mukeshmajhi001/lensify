USE lensify;

ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_image VARCHAR(255) NULL AFTER phone;
ALTER TABLE users ADD COLUMN IF NOT EXISTS bio VARCHAR(255) NULL AFTER profile_image;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_notifications TINYINT(1) NOT NULL DEFAULT 1 AFTER bio;
ALTER TABLE brands ADD COLUMN IF NOT EXISTS description VARCHAR(255) NULL AFTER slug;
ALTER TABLE brands ADD COLUMN IF NOT EXISTS logo_url VARCHAR(500) NULL AFTER description;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS variant_id INT UNSIGNED NULL AFTER product_id;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS variant_name VARCHAR(120) NULL AFTER product_name;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS variant_sku VARCHAR(80) NULL AFTER sku;

CREATE TABLE IF NOT EXISTS user_login_logs (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_login_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS stock_history (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id INT UNSIGNED NOT NULL,
    admin_id INT UNSIGNED NULL,
    quantity_before INT NOT NULL,
    quantity_change INT NOT NULL,
    quantity_after INT NOT NULL,
    note VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_stock_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    CONSTRAINT fk_stock_admin FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS banners (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(180) NOT NULL,
    subtitle VARCHAR(255) NULL,
    image_url VARCHAR(500) NULL,
    button_label VARCHAR(80) NULL,
    button_url VARCHAR(255) NULL,
    sort_order INT NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS reviews (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NULL,
    reviewer_name VARCHAR(160) NOT NULL,
    rating TINYINT UNSIGNED NOT NULL,
    title VARCHAR(180) NULL,
    body TEXT NOT NULL,
    status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS notifications (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    title VARCHAR(160) NOT NULL,
    message VARCHAR(1000) NOT NULL,
    link_url VARCHAR(255) NULL,
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_notification_user_read (user_id, is_read, created_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS return_requests (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NULL,
    reason VARCHAR(180) NOT NULL,
    details TEXT NULL,
    status ENUM('requested','approved','rejected','received','refunded') NOT NULL DEFAULT 'requested',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_return_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_return_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS site_settings (
    setting_key VARCHAR(100) PRIMARY KEY,
    setting_value TEXT NULL,
    updated_by INT UNSIGNED NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_settings_admin FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

INSERT IGNORE INTO site_settings (setting_key, setting_value) VALUES
    ('store_name', 'Lensify'), ('support_email', 'hello@lensify.test'), ('free_shipping_threshold', '2000'),
    ('maintenance_mode', '0'), ('announcement_text', 'Free shipping on orders above ₹2,000');

-- Starter catalogue: every storefront category begins with at least ten frames.
INSERT IGNORE INTO products (category_id, brand_id, name, slug, sku, short_description, description, price, compare_price, stock_quantity, gender, shape, material, color, badge, rating, review_count, is_featured)
SELECT c.id, MOD(n, 8) + 1, CONCAT('Everyday Precision ', n), CONCAT('everyday-precision-', n), CONCAT('LNS-EYE-', LPAD(n, 2, '0')), 'Balanced everyday optical frame.', 'A considered optical frame with a comfortable fit and clean, durable finish.', 4200 + n * 170, 5200 + n * 170, 8 + n, ELT(MOD(n - 1, 4) + 1, 'Men', 'Women', 'Unisex', 'Unisex'), ELT(MOD(n - 1, 5) + 1, 'Rectangular', 'Round', 'Square', 'Cat Eye', 'Wayfarer'), ELT(MOD(n - 1, 3) + 1, 'Acetate', 'Metal', 'TR90'), ELT(MOD(n - 1, 5) + 1, 'Black', 'Gold', 'Tortoise', 'Clear', 'Olive'), CASE WHEN n = 6 THEN 'NEW' ELSE NULL END, 4.8, 0, 0
FROM categories c CROSS JOIN (SELECT 6 AS n UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) AS seed
WHERE c.name = 'Eyeglasses';

INSERT IGNORE INTO products (category_id, brand_id, name, slug, sku, short_description, description, price, compare_price, stock_quantity, gender, shape, material, color, badge, rating, review_count, is_featured)
SELECT c.id, MOD(n + 2, 8) + 1, CONCAT('Sunline Edition ', n), CONCAT('sunline-edition-', n), CONCAT('LNS-SUN-', LPAD(n, 2, '0')), 'UV400 protection with a polished silhouette.', 'Sun-ready eyewear designed for clarity, comfort and reliable UV protection.', 5200 + n * 190, 6500 + n * 190, 8 + n, ELT(MOD(n - 1, 4) + 1, 'Men', 'Women', 'Unisex', 'Unisex'), ELT(MOD(n - 1, 5) + 1, 'Aviator', 'Round', 'Square', 'Cat Eye', 'Wayfarer'), ELT(MOD(n - 1, 3) + 1, 'Metal', 'Acetate', 'TR90'), ELT(MOD(n - 1, 5) + 1, 'Graphite', 'Brown', 'Gold', 'Black', 'Tortoise'), CASE WHEN n = 4 THEN 'NEW' ELSE NULL END, 4.8, 0, 0
FROM categories c CROSS JOIN (SELECT 4 AS n UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) AS seed
WHERE c.name = 'Sunglasses';

INSERT IGNORE INTO products (category_id, brand_id, name, slug, sku, short_description, description, price, compare_price, stock_quantity, gender, shape, material, color, badge, rating, review_count, is_featured)
SELECT c.id, MOD(n + 4, 8) + 1, CONCAT('Focus Reading ', n), CONCAT('focus-reading-', n), CONCAT('LNS-READ-', LPAD(n, 2, '0')), 'Comfort-first reading frame for close work.', 'Lightweight reading glasses made for focused time with books, screens and detailed work.', 3100 + n * 150, 3900 + n * 150, 9 + n, ELT(MOD(n - 1, 4) + 1, 'Women', 'Men', 'Unisex', 'Unisex'), ELT(MOD(n - 1, 5) + 1, 'Round', 'Rectangular', 'Square', 'Cat Eye', 'Wayfarer'), ELT(MOD(n - 1, 3) + 1, 'Acetate', 'TR90', 'Metal'), ELT(MOD(n - 1, 5) + 1, 'Ruby', 'Navy', 'Clear', 'Tortoise', 'Black'), CASE WHEN n = 1 THEN 'NEW' ELSE NULL END, 4.8, 0, 0
FROM categories c CROSS JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) AS seed
WHERE c.name = 'Reading Glasses';

INSERT IGNORE INTO products (category_id, brand_id, name, slug, sku, short_description, description, price, compare_price, stock_quantity, gender, shape, material, color, badge, rating, review_count, is_featured)
SELECT c.id, MOD(n + 6, 8) + 1, CONCAT('Screen Ease ', n), CONCAT('screen-ease-', n), CONCAT('LNS-COMP-', LPAD(n, 2, '0')), 'A relaxed frame for long screen sessions.', 'A versatile frame designed to help make everyday screen time more comfortable.', 3600 + n * 165, 4500 + n * 165, 9 + n, ELT(MOD(n - 1, 4) + 1, 'Unisex', 'Women', 'Men', 'Unisex'), ELT(MOD(n - 1, 5) + 1, 'Square', 'Round', 'Rectangular', 'Cat Eye', 'Wayfarer'), ELT(MOD(n - 1, 3) + 1, 'TR90', 'Acetate', 'Metal'), ELT(MOD(n - 1, 5) + 1, 'Blue', 'Smoke', 'Rose', 'Black', 'Clear'), CASE WHEN n = 1 THEN 'NEW' ELSE NULL END, 4.8, 0, 0
FROM categories c CROSS JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) AS seed
WHERE c.name = 'Computer Glasses';

INSERT INTO product_images (product_id, image_url, alt_text, sort_order)
SELECT p.id, CONCAT(CASE c.name WHEN 'Sunglasses' THEN 'https://images.unsplash.com/photo-1508296695146-257a814070b4?auto=format&fit=crop&w=1000&q=85' WHEN 'Reading Glasses' THEN 'https://images.unsplash.com/photo-1574258495973-f010dfbb5371?auto=format&fit=crop&w=1000&q=85' WHEN 'Computer Glasses' THEN 'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1000&q=85' ELSE 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=1000&q=85' END, '&sig=', p.id), CONCAT(p.name, ' frame'), 0
FROM products p INNER JOIN categories c ON c.id = p.category_id
WHERE (p.sku LIKE 'LNS-EYE-%' OR p.sku LIKE 'LNS-SUN-%' OR p.sku LIKE 'LNS-READ-%' OR p.sku LIKE 'LNS-COMP-%')
  AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.id);
