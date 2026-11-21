<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/_init.php';
requireHttpMethod(['GET']);

$staff = Rbac::requireAuth(null, false);
$role = (string) $staff['role'];

$canRead = Rbac::hasPermission($role, 'orders.read')
    || Rbac::hasPermission($role, 'orders.read_kitchen')
    || Rbac::hasPermission($role, 'orders.read_delivery');

if (!$canRead) {
    jsonResponse(['error' => 'Acesso negado à fila de pedidos.'], 403);
}

$orders = OrderService::listOrdersForStaff($staff, [
    'status' => $_GET['status'] ?? null,
    'zone'   => $_GET['zone'] ?? null,
    'q'      => $_GET['q'] ?? null,
    'limit'  => $_GET['limit'] ?? 50,
]);

jsonResponse([
    'ok'     => true,
    'role'   => $role,
    'count'  => count($orders),
    'orders' => $orders,
]);
