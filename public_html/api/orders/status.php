<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/_init.php';
requireHttpMethod(['PATCH', 'POST']);

$staff = Rbac::requireAuth(null, true);
$role = (string) $staff['role'];

if (
    !Rbac::hasPermission($role, 'orders.update_status') &&
    !Rbac::hasPermission($role, 'orders.cancel_unpaid')
) {
    jsonResponse(['error' => 'Seu perfil não tem permissão para alterar status de pedidos.'], 403);
}

$body = readJsonBody();
$orderId = (int) ($body['order_id'] ?? 0);
$toStatus = (string) ($body['to_status'] ?? '');
$note = isset($body['note']) ? (string) $body['note'] : null;

if ($orderId <= 0 || trim($toStatus) === '') {
    jsonResponse(['error' => 'Informe order_id e to_status.'], 400);
}

$result = OrderService::transitionStatus($orderId, $toStatus, $staff, $note);

jsonResponse([
    'ok'         => true,
    'transition' => $result,
]);
