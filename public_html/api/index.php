<?php
declare(strict_types=1);

require_once __DIR__ . '/_init.php';
requireHttpMethod(['GET']);

jsonResponse([
    'service' => 'O Espanhol API',
    'version' => '2.0',
    'status'  => 'ok',
    'endpoints' => [
        'public' => [
            'GET /api/catalog/regions.php',
            'GET /api/catalog/products.php',
            'GET|POST /api/shipping/quote.php',
            'POST /api/orders/create.php',
            'POST /api/inquiries/corporate.php',
            'POST /api/webhooks/payment.php',
        ],
        'staff_rbac' => [
            'POST /api/auth/login.php',
            'POST /api/auth/logout.php',
            'GET /api/auth/me.php',
            'GET /api/orders/list.php',
            'PATCH|POST /api/orders/status.php',
            'POST|PUT|PATCH /api/catalog/products.php',
            'GET|PATCH /api/inquiries/corporate.php',
            'GET|POST|PATCH /api/admin/staff.php',
            'GET /api/admin/audit.php',
            'GET /api/admin/reports.php',
        ],
    ],
]);
