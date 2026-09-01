<?php
require_once __DIR__ . '/app/bootstrap.php';
http_response_code(404);

// Reuse the latest catalogue image managed from the admin dashboard.
$errorImage = site_setting('error_page_image');
if (db_available()) {
    try {
        if (!$errorImage) {
        $imageStatement = db()->query("SELECT image_url FROM product_images WHERE image_url IS NOT NULL AND image_url <> '' ORDER BY id DESC LIMIT 1");
        $errorImage = $imageStatement->fetchColumn() ?: null;
        }
    } catch (Throwable) {
        $errorImage = null;     
    }
}
$errorImage = $errorImage ? display_image_url((string) $errorImage) : null;
?>
<!doctype html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>404 · Lensify</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link
        href="https://fonts.googleapis.com/css2?family=DM+Mono:wght@400;500&family=Inter:wght@400;500;600;700;800&display=swap"
        rel="stylesheet">
    <style>
    :root {
        --bg: #0b0d14;
        --accent: #7c6af5;
        --accent-light: #9d8ffb;
        --muted: #a3a3b5;
    }

    * {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
    }

    html,
    body {
        min-height: 100%;
    }

    body {
        background: radial-gradient(circle at 50% 30%, rgba(124, 106, 245, .25), transparent 65%), var(--bg);
        color: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
        min-height: 100vh;
        overflow-x: hidden;
        position: relative;
        font-family: Inter, sans-serif;
    }

    .deco {
        position: absolute;
        border-radius: 50%;
        background: var(--accent);
        opacity: .3;
        pointer-events: none;
    }

    .deco.square {
        border-radius: 2px;
    }

    .container {
        width: 100%;
        max-width: 1100px;
        padding: 40px 50px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 50px;
        position: relative;
        z-index: 2;
    }

    .illustration-wrap {
        position: relative;
        flex: 1 1 45%;
        max-width: 480px;
        aspect-ratio: 1;
        margin: 0 auto;
    }

    .illustration-wrap::before {
        content: '';
        position: absolute;
        inset: 8%;
        border-radius: 50%;
        background: radial-gradient(circle, rgba(124, 106, 245, .23), rgba(124, 106, 245, .03) 67%, transparent 68%);
    }

    .illustration {
        position: absolute;
        inset: 10%;
        display: grid;
        place-items: center;
        overflow: visible;
        background: transparent;
    }

    .illustration img {
        width: 100%;
        height: 100%;
        object-fit: contain;
        filter: none;
    }

    .illustration .fallback {
        font-family: 'DM Mono', monospace;
        font-size: 5rem;
        color: var(--accent-light);
    }

    .ghost-404 {
        position: absolute;
        top: 5%;
        left: -8%;
        font-family: 'DM Mono', monospace;
        font-size: clamp(3rem, 8vw, 4.8rem);
        font-weight: 500;
        color: var(--accent);
        opacity: .15;
        letter-spacing: 3px;
        user-select: none;
    }

    .content {
        flex: 1 1 50%;
        text-align: left;
    }

    .eyebrow {
        color: var(--accent-light);
        font-family: 'DM Mono', monospace;
        font-size: .75rem;
        letter-spacing: .18em;
        text-transform: uppercase;
    }

    .code-404 {
        margin-top: 14px;
        color: var(--accent);
        font-family: 'DM Mono', monospace;
        font-size: clamp(3.8rem, 10vw, 5.5rem);
        font-weight: 500;
        line-height: 1;
        letter-spacing: 2px;
        text-shadow: 0 0 40px rgba(124, 106, 245, .5);
    }

    h1 {
        margin-top: 16px;
        font-size: clamp(1.6rem, 3.5vw, 2.2rem);
        font-weight: 800;
        letter-spacing: -.06em;
    }

    p {
        max-width: 460px;
        margin-top: 14px;
        color: var(--muted);
        font-size: clamp(1rem, 1.6vw, 1.15rem);
        line-height: 1.7;
    }

    .btn-home {
        display: inline-flex;
        align-items: center;
        gap: 12px;
        margin-top: 36px;
        padding: 16px 30px;
        border-radius: 14px;
        background: linear-gradient(135deg, var(--accent), #5a47d6);
        color: #fff;
        text-decoration: none;
        font-weight: 700;
        box-shadow: 0 10px 28px rgba(124, 106, 245, .45);
        transition: transform .25s ease, box-shadow .25s ease;
    }

    .btn-home:hover {
        transform: translateY(-4px);
        box-shadow: 0 16px 40px rgba(124, 106, 245, .6);
    }

    .btn-home svg {
        width: 20px;
        height: 20px;
        fill: currentColor;
    }

    @media (max-width:900px) {
        .container {
            flex-direction: column;
            text-align: center;
            padding: 30px 24px;
            max-width: 600px;
            gap: 10px;
        }

        .content {
            text-align: center;
        }

        .illustration-wrap {
            width: 100%;
            max-width: 340px;
            flex: 0 0 auto;
        }

        p {
            margin-left: auto;
            margin-right: auto;
        }

        .ghost-404 {
            left: -4%;
            top: 2%;
        }
    }

    @media (max-width:480px) {
        .container {
            padding: 20px 16px;
        }

        .illustration-wrap {
            max-width: 260px;
        }

        .code-404 {
            font-size: 2.8rem;
        }

        h1 {
            font-size: 1.3rem;
        }

        .btn-home {
            padding: 14px 28px;
            font-size: .95rem;
        }
    }
    </style>
</head>

<body>
    <span class="deco" style="width:10px;height:10px;top:12%;left:6%;"></span>
    <span class="deco square"
        style="width:12px;height:12px;top:20%;left:10%;transform:rotate(25deg);opacity:.25;"></span>
    <span class="deco" style="width:16px;height:16px;top:6%;right:10%;"></span>
    <span class="deco" style="width:8px;height:8px;bottom:22%;left:18%;"></span>
    <span class="deco square"
        style="width:10px;height:10px;bottom:16%;right:14%;transform:rotate(25deg);opacity:.25;"></span>
    <main class="container">
        <div class="illustration-wrap" aria-label="A Lensify frame from the catalogue">
            <span class="ghost-404" aria-hidden="true">404</span>
            <div class="illustration">
                <?php if ($errorImage): ?><img src="<?= h($errorImage) ?>" alt="Lensify catalogue frame">
                <?php else: ?><span class="fallback" aria-hidden="true">LF</span><?php endif; ?>
            </div>
        </div>
        <div class="content">
            <div class="eyebrow">Error 404</div>
            <div class="code-404">404</div>
            <h1>Oops! Page not found.</h1>
            <p>Looks like you've lost your way.<br>The page you're looking for doesn't exist or has been moved.</p>
            <a href="<?= h(url()) ?>" class="btn-home"><svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M12 3l9 8h-3v9h-5v-6H11v6H6v-9H3z" />
                </svg>Go Home</a>
        </div>
    </main>
</body>

</html>