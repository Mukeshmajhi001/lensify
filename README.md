# Lensify

Premium eyewear e-commerce storefront built with plain PHP 8, MySQL/MariaDB and Tailwind CSS (CDN). The interface follows the supplied Lensify design system: editorial typography, monochrome palette, generous whitespace and minimal borders.

## Included

- Responsive homepage, product listing/search/filtering and product details
- Lens-type selection, session bag, checkout and persisted orders
- Customer registration with optional profile photo, profile settings, order history, saved frames and contact form
- Full responsive navigation for mobile, tablet and desktop, including the signed-in customer profile chip
- Admin console with dashboard shortcuts, products/variants, category and brand management, stock history, banners, coupons, review moderation, returns, reporting, customer records, activity logs and settings
- MySQL schema with sample products, brands, categories, images and an admin account

## Run locally with XAMPP

1. Start **Apache** and **MySQL** in XAMPP.
2. Import [database/schema.sql](database/schema.sql) into MariaDB/MySQL. From PowerShell:

   ```powershell
   Get-Content -Raw .\database\schema.sql | D:\xampp\mysql\bin\mysql.exe -u root
   ```

3. Open [http://localhost/codex_lensify/](http://localhost/codex_lensify/).

If you are upgrading an existing Lensify database, apply the migrations once, in this order:

```powershell
Get-Content -Raw .\database\migrate_admin_expansion.sql | D:\xampp\mysql\bin\mysql.exe -u root lensify
Get-Content -Raw .\database\migrate_customer_requirements.sql | D:\xampp\mysql\bin\mysql.exe -u root lensify
Get-Content -Raw .\database\migrate_order_cancellation.sql | D:\xampp\mysql\bin\mysql.exe -u root lensify
Get-Content -Raw .\database\migrate_shipping_and_order_message.sql | D:\xampp\mysql\bin\mysql.exe -u root lensify
```

The default local database configuration is `127.0.0.1`, database `lensify`, user `root`, with no password. Override it with `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` and `DB_PASS` environment variables if needed.

## Demo administrator

- URL: [http://localhost/codex_lensify/admin/login.php](http://localhost/codex_lensify/admin/login.php)
- Email: `admin@lensify.test`
- Password: `Admin@12345`

Change this password before a production deployment.

## Important production notes

- UPI, digital-wallet, and card checkout intentionally show a “not available yet” message. Connect a real payment gateway and webhook before enabling them.
- Product images are currently externally hosted sample image URLs. Upload/store owned product photography before launch.
- Profile and banner uploads are stored under `uploads/`; ensure this folder is writable by the PHP process on your hosting environment.
- Replace the placeholder legal copy in `privacy.php` and `terms.php` with business-approved policies.
