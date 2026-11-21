<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/_init.php';
requireHttpMethod(['GET']);

$user = Rbac::requireAuth(null, false);

jsonResponse([
    'ok'         => true,
    'csrf_token' => Rbac::csrfToken(),
    'user'       => $user,
]);
