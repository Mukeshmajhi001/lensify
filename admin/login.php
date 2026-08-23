<?php
require_once dirname(__DIR__) . '/app/bootstrap.php';
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'admin_login') {
    if (!verify_csrf()) {
        http_response_code(419);
        exit('This form has expired.');
    }
    $email = filter_var(trim((string) ($_POST['email'] ?? '')), FILTER_VALIDATE_EMAIL);
    $password = (string) ($_POST['password'] ?? '');
    if (!$email || !$password || !db_available()) {
        flash('error', db_available() ? 'Enter a valid email and password.' : 'Database is not ready. Import database/schema.sql first.');
    } else {
        $statement = db()->prepare("SELECT * FROM users WHERE email = ? AND role = 'admin' AND is_active = 1 LIMIT 1");
        $statement->execute([$email]);
        $user = $statement->fetch();
        if ($user && password_verify($password, $user['password_hash'])) {
            session_regenerate_id(true);
            $_SESSION['user_id'] = $user['id'];
            db()->prepare('INSERT INTO admin_logs (admin_id, event, ip_address) VALUES (?, ?, ?)')->execute([$user['id'], 'Admin signed in', $_SERVER['REMOTE_ADDR'] ?? null]);
            db()->prepare('INSERT INTO user_login_logs (user_id, ip_address, user_agent) VALUES (?, ?, ?)')->execute([$user['id'], $_SERVER['REMOTE_ADDR'] ?? null, substr((string) ($_SERVER['HTTP_USER_AGENT'] ?? ''), 0, 255)]);
            redirect('admin/index.php');
        }
        flash('error', 'Incorrect admin credentials.');
    }
}
if (is_admin()) {
    redirect('admin/index.php');
}
?>
<!doctype html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin sign in · Lensify</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
    <link
        href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=swap"
        rel="stylesheet">
    <link href="<?= h(url('assets/css/app.css')) ?>" rel="stylesheet">
</head>

<body class="grid min-h-screen place-items-center bg-[#fbf9f9] p-5 font-sans text-zinc-900">
    <main class="w-full max-w-md rounded-2xl border border-zinc-200 bg-white p-7 shadow-soft sm:p-9"><a
            class="flex items-center gap-3" href="<?= h(url()) ?>"><span
                class="grid h-10 w-10 place-items-center rounded-lg bg-black text-white"><span
                    class="material-symbols-outlined">visibility</span></span><span><strong
                    class="block text-lg tracking-[-.05em]">Lensify</strong><small
                    class="text-[10px] font-semibold uppercase tracking-[.13em] text-zinc-500">Admin
                    console</small></span></a>
        <h1 class="mt-10 text-3xl font-bold tracking-[-.05em]">Welcome back</h1>
        <p class="mt-2 text-sm text-zinc-500">Sign in to manage the Lensify store.</p>
        <?php if ($error = flash('error')): ?><p class="mt-5 rounded-lg bg-red-50 p-3 text-sm text-red-700">
                <?= h($error) ?></p><?php endif; ?><form class="mt-7 space-y-5" method="post"><?= csrf_field() ?><input
                type="hidden" name="action" value="admin_login">
            <div><label class="label">Admin email</label><input class="input" type="email" name="email" required
                    value=""></div>
            <div><label class="label">Password</label><input class="input" type="password" name="password" required
                    value=""></div><button class="button button-primary w-full" type="submit">Sign in to
                console</button>
        </form>
        <p class="mt-6 text-center text-xs text-zinc-500"><a class="underline" href="<?= h(url()) ?>">← Back to
                store</a></p>
    </main>
</body>

</html>