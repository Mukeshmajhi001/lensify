CREATE DATABASE IF NOT EXISTS lensify CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE lensify;

CREATE TABLE IF NOT EXISTS users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    email VARCHAR(190) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(40) NULL,
    profile_image VARCHAR(255) NULL,
    bio VARCHAR(255) NULL,
    email_notifications TINYINT(1) NOT NULL DEFAULT 1,
    role ENUM('customer', 'admin') NOT NULL DEFAULT 'customer',
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS categories (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(120) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,
    icon VARCHAR(60) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS brands (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(120) NOT NULL UNIQUE,
    description VARCHAR(255) NULL,
    logo_url VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS products (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id INT UNSIGNED NOT NULL,
    brand_id INT UNSIGNED NOT NULL,
    name VARCHAR(180) NOT NULL,
    slug VARCHAR(200) NOT NULL UNIQUE,
    sku VARCHAR(80) NOT NULL UNIQUE,
    short_description VARCHAR(500) NULL,
    description TEXT NULL,
    price DECIMAL(10,2) NOT NULL,
    compare_price DECIMAL(10,2) NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    gender ENUM('Men', 'Women', 'Kids', 'Unisex') NOT NULL DEFAULT 'Unisex',
    shape VARCHAR(50) NOT NULL,
    material VARCHAR(80) NOT NULL,
    color VARCHAR(80) NOT NULL,
    badge VARCHAR(30) NULL,
    rating DECIMAL(2,1) NOT NULL DEFAULT 4.8,
    review_count INT UNSIGNED NOT NULL DEFAULT 0,
    is_featured TINYINT(1) NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories(id),
    CONSTRAINT fk_product_brand FOREIGN KEY (brand_id) REFERENCES brands(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS product_images (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id INT UNSIGNED NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255) NULL,
    sort_order INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_image_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS product_variants (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id INT UNSIGNED NOT NULL,
    name VARCHAR(120) NOT NULL,
    sku VARCHAR(80) NOT NULL UNIQUE,
    color VARCHAR(80) NULL,
    price_adjustment DECIMAL(10,2) NOT NULL DEFAULT 0,
    stock_quantity INT NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT fk_variant_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS addresses (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    label VARCHAR(40) NOT NULL DEFAULT 'Home',
    recipient_name VARCHAR(160) NOT NULL,
    phone VARCHAR(40) NOT NULL,
    line1 VARCHAR(190) NOT NULL,
    line2 VARCHAR(190) NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'Nepal',
    is_default TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_address_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS orders (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(30) NOT NULL UNIQUE,
    user_id INT UNSIGNED NULL,
    customer_name VARCHAR(160) NOT NULL,
    customer_email VARCHAR(190) NOT NULL,
    customer_phone VARCHAR(40) NOT NULL,
    delivery_address TEXT NOT NULL,
    customer_message VARCHAR(1000) NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    shipping_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
    order_status ENUM('processing', 'confirmed', 'shipped', 'delivered', 'cancelled', 'returned') NOT NULL DEFAULT 'processing',
    cancellation_reason VARCHAR(1000) NULL,
    cancelled_by INT UNSIGNED NULL,
    cancelled_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_order_cancelled_by FOREIGN KEY (cancelled_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS order_items (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NULL,
    variant_id INT UNSIGNED NULL,
    product_name VARCHAR(180) NOT NULL,
    product_image_url VARCHAR(500) NULL,
    variant_name VARCHAR(120) NULL,
    sku VARCHAR(80) NOT NULL,
    variant_sku VARCHAR(80) NULL,
    lens_type VARCHAR(80) NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    line_total DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_order_item_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL,
    CONSTRAINT fk_order_item_variant FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS wishlists (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_wishlist (user_id, product_id),
    CONSTRAINT fk_wishlist_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_wishlist_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS coupons (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    type ENUM('percent', 'fixed') NOT NULL,
    value DECIMAL(10,2) NOT NULL,
    minimum_order DECIMAL(10,2) NOT NULL DEFAULT 0,
    starts_at DATETIME NULL,
    expires_at DATETIME NULL,
    usage_limit INT NULL,
    used_count INT NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS contact_messages (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(160) NOT NULL,
    email VARCHAR(190) NOT NULL,
    subject VARCHAR(180) NOT NULL,
    message TEXT NOT NULL,
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS admin_logs (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    admin_id INT UNSIGNED NULL,
    event VARCHAR(190) NOT NULL,
    ip_address VARCHAR(45) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_admin FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

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
    UNIQUE KEY uniq_review_product_user (product_id, user_id),
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

INSERT IGNORE INTO categories (id, name, slug, description, icon) VALUES
    (1, 'Eyeglasses', 'eyeglasses', 'Everyday frames, precisely made', 'eyeglasses'),
    (2, 'Sunglasses', 'sunglasses', 'Protection with a point of view', 'sunglasses'),
    (3, 'Reading Glasses', 'reading-glasses', 'Focused comfort for close work', 'menu_book'),
    (4, 'Computer Glasses', 'computer-glasses', 'Designed for screen time', 'computer');

INSERT IGNORE INTO brands (id, name, slug) VALUES
    (1, 'Lumina Eyewear', 'lumina-eyewear'), (2, 'Vintage Co.', 'vintage-co'),
    (3, 'Moderna', 'moderna'), (4, 'Steel & Sky', 'steel-sky'),
    (5, 'Crystal Vision', 'crystal-vision'), (6, 'Earth Eyewear', 'earth-eyewear'),
    (7, 'Metals', 'metals'), (8, 'Retro Gold', 'retro-gold');

INSERT IGNORE INTO products (id, category_id, brand_id, name, slug, sku, short_description, description, price, compare_price, stock_quantity, gender, shape, material, color, badge, rating, review_count, is_featured) VALUES
    (1,1,1,'Noir Arch Rectangular','noir-arch-rectangular','LUM-NOIR-001','Architectural acetate, confident all day.','A confident everyday silhouette in hand-finished Italian acetate, made to keep its poise from first meeting to last light.',4800,6200,14,'Men','Rectangular','Acetate','Midnight Black','SALE',4.8,124,1),
    (2,1,2,'Aurelia Round Metal','aurelia-round-metal','VIN-AUR-002','Refined round metal frame.','An ultra-light round metal frame with warm gold detailing and a refined, almost weightless fit.',5900,NULL,9,'Women','Round','Metal','Champagne Gold','BESTSELLER',4.9,89,1),
    (3,1,3,'Amber Cat Eye','amber-cat-eye','MOD-AMB-003','A sculpted tortoise cat-eye.','A sculpted cat-eye profile in rich tortoise acetate, cut for an effortless, editorial statement.',6900,NULL,8,'Women','Cat Eye','Acetate','Tortoise',NULL,4.7,61,1),
    (4,2,4,'Titan Flight Aviator','titan-flight-aviator','SSK-TIT-004','Featherlight titanium aviators.','Titanium aviators with a crisp profile, featherlight fit and complete UV protection.',7450,NULL,11,'Unisex','Aviator','Titanium','Graphite','NEW',4.9,156,1),
    (5,1,5,'Ice Square Frame','ice-square-frame','CRY-ICE-005','Modern transparent acetate.','Transparent acetate turns a precise square frame into a clean, modern essential.',5100,NULL,12,'Unisex','Square','Acetate','Crystal Clear',NULL,4.6,47,0),
    (6,1,6,'Eco-Round Matte Green','eco-round-matte-green','EAR-ECO-006','Rounded low-impact frame.','A gently rounded, low-impact frame with a velvety matte finish and spring hinges.',4500,5200,4,'Unisex','Round','Eco-friendly','Forest Green','SALE',4.5,38,0),
    (7,2,7,'Slate Aviator','slate-aviator','MET-SLA-007','Minimal metal, maximum sun coverage.','Dark lenses and a minimal metal bridge make this a versatile warm-weather classic.',6200,NULL,6,'Men','Aviator','Metal','Slate','NEW',4.8,73,0),
    (8,2,8,'Scarlet Cat','scarlet-cat','RET-SCA-008','Optimistic red cat-eye.','A sun-ready cat-eye in an optimistic red with full UV400 protection.',5400,NULL,3,'Women','Cat Eye','Acetate','Scarlet','LIMITED',4.7,52,0);

INSERT IGNORE INTO product_images (product_id, image_url, alt_text, sort_order) VALUES
    (1,'https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=1000&q=85','Noir Arch Rectangular frame',0),
    (2,'https://images.unsplash.com/photo-1574258495973-f010dfbb5371?auto=format&fit=crop&w=1000&q=85','Aurelia Round Metal frame',0),
    (3,'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=1000&q=85','Amber Cat Eye frame',0),
    (4,'https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=1000&q=85&sat=-100','Titan Flight Aviator',0),
    (5,'https://images.unsplash.com/photo-1514308582979-6b00088e7f57?auto=format&fit=crop&w=1000&q=85','Ice Square Frame',0),
    (6,'https://images.unsplash.com/photo-1577803645773-f96470509666?auto=format&fit=crop&w=1000&q=85','Eco-Round Matte Green',0),
    (7,'https://images.unsplash.com/photo-1508296695146-257a814070b4?auto=format&fit=crop&w=1000&q=85','Slate Aviator',0),
    (8,'https://images.unsplash.com/photo-1512316609839-ce289d3eba0a?auto=format&fit=crop&w=1000&q=85','Scarlet Cat',0);

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

-- Keep every category useful from the first import. Categories made later by an
-- administrator are brought to ten frames by the upgrade migration below.
INSERT IGNORE INTO products (category_id, brand_id, name, slug, sku, short_description, description, price, compare_price, stock_quantity, gender, shape, material, color, badge, rating, review_count, is_featured)
SELECT c.id, MOD(shape_seed.position + shape_copy.occurrence + 1, 8) + 1, CONCAT(c.name, ' ', shape_seed.shape, ' Collection ', shape_copy.occurrence), CONCAT(c.slug, '-', LOWER(REPLACE(shape_seed.shape, ' ', '-')), '-collection-', shape_copy.occurrence), CONCAT('LNS-', UPPER(LEFT(c.slug, 18)), '-', shape_seed.position, '-', shape_copy.occurrence), 'A versatile, comfortable everyday frame.', 'A carefully finished frame with a balanced shape, durable materials and a comfortable fit.', 4800 + shape_seed.position * 125, NULL, 12, 'Unisex', shape_seed.shape, 'Acetate', ELT(shape_seed.position, 'Black', 'Gold', 'Tortoise', 'Clear', 'Olive'), NULL, 4.8, 0, 0
FROM categories c
INNER JOIN (SELECT 1 AS position, 'Rectangular' AS shape UNION ALL SELECT 2, 'Round' UNION ALL SELECT 3, 'Square' UNION ALL SELECT 4, 'Cat Eye' UNION ALL SELECT 5, 'Wayfarer') AS shape_seed
CROSS JOIN (SELECT 1 AS occurrence UNION ALL SELECT 2) AS shape_copy
WHERE shape_copy.occurrence <= (2 - (SELECT COUNT(*) FROM products p WHERE p.category_id = c.id AND p.shape = shape_seed.shape));

INSERT INTO product_images (product_id, image_url, alt_text, sort_order)
SELECT p.id, CONCAT(CASE c.name WHEN 'Sunglasses' THEN 'https://images.unsplash.com/photo-1508296695146-257a814070b4?auto=format&fit=crop&w=1000&q=85' WHEN 'Reading Glasses' THEN 'https://images.unsplash.com/photo-1574258495973-f010dfbb5371?auto=format&fit=crop&w=1000&q=85' WHEN 'Computer Glasses' THEN 'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1000&q=85' ELSE 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=1000&q=85' END, '&sig=', p.id), CONCAT(p.name, ' frame'), 0
FROM products p INNER JOIN categories c ON c.id = p.category_id
WHERE NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.id);

INSERT IGNORE INTO users (first_name, last_name, email, password_hash, role) VALUES
    ('Lensify', 'Admin', 'admin@lensify.test', '$2y$10$9DozUGSP.tXdaD4gf2VmAu9oCos9YueGSjqleSf1iNP7V1KAomrRW', 'admin');

INSERT IGNORE INTO coupons (code, type, value, minimum_order, is_active) VALUES
    ('WELCOME10', 'percent', 10, 3000, 1);

INSERT IGNORE INTO site_settings (setting_key, setting_value) VALUES
    ('store_name', 'Lensify'), ('support_email', 'hello@lensify.test'), ('free_shipping_threshold', '2000'),
    ('maintenance_mode', '0'), ('announcement_text', 'Free shipping on orders above ₹2,000');
