</main>
<footer class="mt-16 border-t border-zinc-200 bg-[#eef1fb]">
    <div class="mx-auto grid max-w-[1440px] gap-10 px-5 py-12 sm:grid-cols-2 lg:grid-cols-4 lg:px-10">
        <div><a class="text-xl font-bold tracking-[-.08em]" href="<?= h(url()) ?>">Lensify</a>
            <p class="mt-4 max-w-xs text-sm leading-6 text-zinc-600">Premium eyewear designed for the modern individual.
                Quality, style and clarity above all else.</p>
        </div>
        <div>
            <h2 class="footer-heading">Shop</h2>
            <div class="footer-links"><a href="<?= h(url('shop.php?category=Eyeglasses')) ?>">Eyeglasses</a><a
                    href="<?= h(url('shop.php?category=Sunglasses')) ?>">Sunglasses</a><a
                    href="<?= h(url('shop.php?category=Computer+Glasses')) ?>">Computer Glasses</a><a
                    href="<?= h(url('wishlist.php')) ?>">Saved frames</a></div>
        </div>
        <div>
            <h2 class="footer-heading">Support</h2>
            <div class="footer-links"><a href="<?= h(url('contact.php')) ?>">Contact us</a><a
                    href="<?= h(url('orders.php')) ?>">Orders & returns</a><a
                    href="<?= h(url('privacy.php')) ?>">Privacy policy</a><a href="<?= h(url('terms.php')) ?>">Terms &
                    conditions</a></div>
        </div>
        <div>
            <h2 class="footer-heading">Stay in the frame</h2>
            <p class="mb-3 text-sm text-zinc-600">New collections and member-only offers.</p>
            <form class="flex gap-2" action="#" onsubmit="return false"><input class="input min-w-0"
                    aria-label="Email address" placeholder="Your email address" type="email"><button
                    class="button button-primary px-4" type="submit">Join</button></form>
        </div>
    </div>
    <div
        class="mx-auto flex max-w-[1440px] flex-col gap-3 border-t border-zinc-200 px-5 py-5 text-xs text-zinc-500 sm:flex-row sm:justify-between lg:px-10">
        <span>© <?= date('Y') ?> Lensify. All rights reserved.</span><span>Designed with precision in Nepal.</span>
    </div>
</footer>
<script src="<?= h(url('assets/js/app.js')) ?>"></script>
</body>

</html>