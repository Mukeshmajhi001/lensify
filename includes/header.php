<?php
require_once APP_ROOT . '/app/bootstrap.php';
$pageTitle = $pageTitle ?? 'Premium Eyewear';
$activeCategory = $activeCategory ?? '';
$currentPath = basename(parse_url($_SERVER['REQUEST_URI'] ?? '', PHP_URL_PATH) ?: 'index.php');
$success = flash('success');
$error = flash('error');
$viewer = current_user();
$viewerAvatar = avatar_url($viewer);
$unreadNotifications = $viewer ? unread_notification_count((int) $viewer['id']) : 0;
?>
<!doctype html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Lensify — premium eyewear for modern vision.">
    <title><?= h($pageTitle) ?> · Lensify</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['Inter', 'sans-serif']
                    },
                    colors: {
                        ink: '#151c27',
                        paper: '#f9f9ff',
                        mist: '#f0f3ff',
                        line: '#e5e7eb',
                        success: '#006e2d'
                    },
                    boxShadow: {
                        soft: '0 4px 20px rgba(0,0,0,.04)'
                    }
                }
            }
        }
    </script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link
        href="https://fonts.googleapis.com/css2?family=DM+Mono&family=Inter:ital,wght@0,400;0,500;0,600;0,700;0,800;1,300;1,400&family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=swap"
        rel="stylesheet">
    <link href="<?= h(url('assets/css/app.css')) ?>" rel="stylesheet">
</head>

<body class="min-h-screen bg-paper font-sans text-ink antialiased">
    <div class="bg-black px-4 py-2.5 text-center text-[11px] font-semibold tracking-[.04em] text-white">Free shipping on
        orders above ₹2,000</div>
    <header
        class="sticky top-0 z-40 border-b border-zinc-200 bg-paper/95 shadow-[0_2px_16px_rgba(0,0,0,.025)] backdrop-blur">
        <div class="mx-auto flex h-20 max-w-[1440px] items-center justify-between gap-4 px-4 sm:px-6 lg:h-24 lg:px-10">
            <a class="flex items-center gap-2 text-2xl font-extrabold tracking-[-.09em] sm:text-[27px]"
                href="<?= h(url()) ?>"><span
                    class="grid h-9 w-9 place-items-center rounded-xl bg-black text-sm tracking-normal text-white">L</span>Lensify</a>
            <nav class="hidden items-center gap-7 xl:flex" aria-label="Main navigation">
                <?php foreach (['Eyeglasses', 'Sunglasses', 'Reading Glasses', 'Computer Glasses'] as $category): ?>
                    <a class="nav-link <?= $activeCategory === $category ? 'nav-link-active' : '' ?>"
                        href="<?= h(url('shop.php?category=' . rawurlencode($category))) ?>"><?= h($category) ?></a>
                <?php endforeach; ?>
                <a class="nav-link" href="<?= h(url('shop.php?sort=price_asc')) ?>">Offers</a>
            </nav>
            <div class="flex items-center gap-1 sm:gap-2">
                <a class="icon-button hidden md:inline-flex" href="<?= h(url('shop.php')) ?>" aria-label="Search"><span
                        class="material-symbols-outlined">search</span></a>
                <a class="profile-nav-button" href="<?= h(url($viewer ? 'account.php' : 'login.php')) ?>"
                    aria-label="<?= $viewer ? 'My profile' : 'Sign in' ?>"><?php if ($viewerAvatar): ?><img
                            class="h-full w-full object-cover" src="<?= h($viewerAvatar) ?>"
                            alt="<?= h($viewer['first_name']) ?>"><?php elseif ($viewer): ?><span><?= h(initials($viewer)) ?></span><?php else: ?><span
                            class="material-symbols-outlined">person</span><?php endif; ?><span
                        class="hidden text-xs font-bold xl:inline"><?= $viewer ? h($viewer['first_name']) : 'Sign in' ?></span></a>
                <?php if ($viewer && !is_admin()): ?><a class="icon-button relative"
                        href="<?= h(url('notifications.php')) ?>" aria-label="Notifications"><span
                            class="material-symbols-outlined">notifications</span><?php if ($unreadNotifications): ?><span
                                class="absolute -right-1 -top-1 grid h-4 min-w-4 place-items-center rounded-full bg-success px-1 text-[9px] font-bold text-white"><?= $unreadNotifications ?></span><?php endif; ?></a><?php endif; ?>
                <a class="icon-button" href="<?= h(url('wishlist.php')) ?>" aria-label="Wishlist"><span
                        class="material-symbols-outlined">favorite</span></a>
                <a class="icon-button relative" href="<?= h(url('cart.php')) ?>" aria-label="Shopping bag"><span
                        class="material-symbols-outlined">shopping_bag</span><?php if (cart_count()): ?><span
                            class="absolute -right-1 -top-1 grid h-4 min-w-4 place-items-center rounded-full bg-success px-1 text-[9px] font-bold text-white"><?= cart_count() ?></span><?php endif; ?></a>
                <button class="icon-button xl:hidden" type="button" data-menu-toggle aria-expanded="false"
                    aria-controls="mobile-navigation" aria-label="Open navigation"><span
                        class="material-symbols-outlined">menu</span></button>
            </div>
        </div>
        <div class="border-t border-zinc-200 bg-white px-4 py-3 xl:hidden">
            <form class="mx-auto flex max-w-[1440px] items-center gap-2" action="<?= h(url('shop.php')) ?>" method="get"
                role="search">
                <label class="sr-only" for="mobile-search">Search frames</label>
                <span class="material-symbols-outlined text-zinc-500">search</span>
                <input
                    class="min-w-0 flex-1 border-0 bg-transparent p-0 text-sm text-zinc-900 placeholder:text-zinc-400 focus:ring-0"
                    id="mobile-search" name="q" placeholder="Search frames, shapes or brands" type="search"
                    value="<?= h($_GET['q'] ?? '') ?>">
                <button class="rounded-lg bg-black px-3 py-2 text-xs font-bold text-white" type="submit">Search</button>
            </form>
        </div>
        <nav class="hidden border-t border-zinc-200 bg-white px-4 py-4 shadow-soft xl:hidden" id="mobile-navigation"
            data-menu aria-label="Mobile navigation">
            <div class="mx-auto grid max-w-[1440px] gap-2 sm:grid-cols-2">
                <?php foreach (['Eyeglasses', 'Sunglasses', 'Reading Glasses', 'Computer Glasses'] as $category): ?>
                    <a class="mobile-nav-link <?= $activeCategory === $category ? 'mobile-nav-link-active' : '' ?>"
                        href="<?= h(url('shop.php?category=' . rawurlencode($category))) ?>"><span><?= h($category) ?></span><span
                            class="material-symbols-outlined">arrow_forward</span></a>
                <?php endforeach; ?>
                <a class="mobile-nav-link" href="<?= h(url('shop.php?sort=price_asc')) ?>"><span>Offers</span><span
                        class="material-symbols-outlined">arrow_forward</span></a>
            </div>
        </nav>
    </header>
    <?php if ($success || $error): ?>
        <div class="fixed right-4 top-24 z-50 max-w-sm rounded-xl border px-4 py-3 text-sm shadow-soft <?= $error ? 'border-red-200 bg-red-50 text-red-800' : 'border-green-200 bg-green-50 text-green-800' ?>"
            data-flash><?= h($error ?: $success) ?></div>
    <?php endif; ?>
    <main>