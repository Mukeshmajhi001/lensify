USE lensify;

-- Preserve the image that was visible when an order was placed, so "My orders"
-- continues to show the correct product after catalogue images are changed.
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS product_image_url VARCHAR(500) NULL AFTER product_name;

UPDATE order_items oi
SET oi.product_image_url = (
    SELECT pi.image_url
    FROM product_images pi
    WHERE pi.product_id = oi.product_id
    ORDER BY pi.sort_order, pi.id
    LIMIT 1
)
WHERE (oi.product_image_url IS NULL OR oi.product_image_url = '')
  AND oi.product_id IS NOT NULL;

-- One customer can submit one review per purchased frame. Application code also
-- verifies that the order is both paid and delivered before this row is created.
ALTER TABLE reviews ADD UNIQUE INDEX IF NOT EXISTS uniq_review_product_user (product_id, user_id);

-- Bring any existing category with fewer than ten products up to ten without
-- touching products that an administrator has already entered.
INSERT IGNORE INTO products (category_id, brand_id, name, slug, sku, short_description, description, price, compare_price, stock_quantity, gender, shape, material, color, badge, rating, review_count, is_featured)
SELECT c.id,
       MOD(seed.n, 8) + 1,
       CONCAT(c.name, ' Starter Frame ', seed.n),
       CONCAT(c.slug, '-starter-frame-', LPAD(seed.n, 2, '0')),
       CONCAT('CAT-', UPPER(LEFT(c.slug, 36)), '-', LPAD(seed.n, 2, '0')),
       'A comfortable everyday frame.',
       'A well-balanced frame added to keep this category ready for customers to browse.',
       4200 + seed.n * 140,
       NULL,
       10 + seed.n,
       'Unisex',
       ELT(MOD(seed.n - 1, 5) + 1, 'Rectangular', 'Round', 'Square', 'Cat Eye', 'Wayfarer'),
       ELT(MOD(seed.n - 1, 3) + 1, 'Acetate', 'Metal', 'TR90'),
       ELT(MOD(seed.n - 1, 5) + 1, 'Black', 'Gold', 'Tortoise', 'Clear', 'Olive'),
       NULL,
       4.8,
       0,
       0
FROM categories c
CROSS JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) AS seed
WHERE seed.n <= (10 - (SELECT COUNT(*) FROM products existing WHERE existing.category_id = c.id));

-- Each standard frame shape has at least two choices in every category. This
-- produces a useful 2–3 option shape group without duplicating an image row.
INSERT IGNORE INTO products (category_id, brand_id, name, slug, sku, short_description, description, price, compare_price, stock_quantity, gender, shape, material, color, badge, rating, review_count, is_featured)
SELECT c.id,
       MOD(shape_seed.position + shape_copy.occurrence + 1, 8) + 1,
       CONCAT(c.name, ' ', shape_seed.shape, ' Collection ', shape_copy.occurrence),
       CONCAT(c.slug, '-', LOWER(REPLACE(shape_seed.shape, ' ', '-')), '-collection-', shape_copy.occurrence),
       CONCAT('LNS-', UPPER(LEFT(c.slug, 18)), '-', shape_seed.position, '-', shape_copy.occurrence),
       'A versatile, comfortable everyday frame.',
       'A carefully finished frame with a balanced shape, durable materials and a comfortable fit.',
       4800 + shape_seed.position * 125,
       NULL,
       12,
       'Unisex',
       shape_seed.shape,
       'Acetate',
       ELT(shape_seed.position, 'Black', 'Gold', 'Tortoise', 'Clear', 'Olive'),
       NULL,
       4.8,
       0,
       0
FROM categories c
INNER JOIN (SELECT 1 AS position, 'Rectangular' AS shape UNION ALL SELECT 2, 'Round' UNION ALL SELECT 3, 'Square' UNION ALL SELECT 4, 'Cat Eye' UNION ALL SELECT 5, 'Wayfarer') AS shape_seed
CROSS JOIN (SELECT 1 AS occurrence UNION ALL SELECT 2) AS shape_copy
WHERE shape_copy.occurrence <= (2 - (SELECT COUNT(*) FROM products p WHERE p.category_id = c.id AND p.shape = shape_seed.shape));

-- New catalogue frames receive exactly one default image. Admin-added gallery
-- images remain untouched and product pages only render the images that exist.
INSERT INTO product_images (product_id, image_url, alt_text, sort_order)
SELECT p.id,
       CONCAT(
           CASE c.name
               WHEN 'Sunglasses' THEN 'https://images.unsplash.com/photo-1508296695146-257a814070b4?auto=format&fit=crop&w=1000&q=85'
               WHEN 'Reading Glasses' THEN 'https://images.unsplash.com/photo-1574258495973-f010dfbb5371?auto=format&fit=crop&w=1000&q=85'
               WHEN 'Computer Glasses' THEN 'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1000&q=85'
               ELSE 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=1000&q=85'
           END,
           '&sig=', p.id
       ),
       CONCAT(p.name, ' frame'),
       0
FROM products p
INNER JOIN categories c ON c.id = p.category_id
WHERE NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = p.id);
