<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/_init.php';
requireHttpMethod(['POST']);

$body = readJsonBody();

// Se for um pedido assistido registrado por empregado logado com permissão, associa o staff_id
$assistedByStaffId = null;
if (!empty($body['assisted_mode'])) {
    $staff = Rbac::requireAuth('orders.create_assisted', true);
    $assistedByStaffId = (int) $staff['id'];
}

$order = OrderService::createOrder($body, $assistedByStaffId);

jsonResponse([
    'ok'    => true,
    'order' => $order,
], 201);
