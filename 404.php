<?php
require_once __DIR__ . '/app/bootstrap.php';
http_response_code(404);
$pageTitle = 'Page not found';
require APP_ROOT . '/includes/header.php';
?>
<section class="mx-auto flex min-h-[62vh] max-w-3xl items-center justify-center px-5 py-16 text-center lg:px-10">
    <div>
        <span class="material-symbols-outlined text-6xl text-zinc-300" aria-hidden="true">visibility_off</span>
        <p class="label mt-6">Error 404</p>
        <h1 class="mt-3 text-5xl font-extrabold tracking-[-.07em] sm:text-6xl">This page is out of focus.</h1>
        <p class="mx-auto mt-5 max-w-md text-sm leading-7 text-zinc-600">
            The page you are looking for may have moved, or the link may be incorrect.
        </p>
        <div class="mt-8 flex flex-wrap justify-center gap-3">
            <a class="button button-primary" href="<?= h(url()) ?>">Back to home <span
                    class="material-symbols-outlined text-base" aria-hidden="true">arrow_forward</span></a>
            <a class="button button-secondary" href="<?= h(url('shop.php')) ?>">Browse frames</a>
        </div>
    </div>
</section>
<?php require APP_ROOT . '/includes/footer.php'; ?>
