<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/_init.php';
requireHttpMethod(['GET']);

// Exclusivo para ADMIN (audit.read)
Rbac::requireAuth('audit.read', false);
$pdo = Database::connection();

$where = ['1 = 1'];
$params = [];

if (!empty($_GET['action'])) {
    $where[] = 'al.action = :action';
    $params[':action'] = trim((string) $_GET['action']);
}
if (!empty($_GET['entity_type'])) {
    $where[] = 'al.entity_type = :etype';
    $params[':etype'] = trim((string) $_GET['entity_type']);
}
if (!empty($_GET['staff_user_id'])) {
    $where[] = 'al.staff_user_id = :sid';
    $params[':sid'] = (int) $_GET['staff_user_id'];
}

$limit = max(1, min(200, (int) ($_GET['limit'] ?? 60)));

$stmt = $pdo->prepare(
    'SELECT al.id, al.staff_user_id, su.full_name AS staff_name, su.role AS staff_role,
            al.action, al.entity_type, al.entity_id,
            al.old_values_json, al.new_values_json, al.ip_address, al.created_at
       FROM audit_logs al
       LEFT JOIN staff_users su ON su.id = al.staff_user_id
      WHERE ' . implode(' AND ', $where) . '
      ORDER BY al.created_at DESC
      LIMIT ' . $limit
);
$stmt->execute($params);

$logs = array_map(static function (array $row): array {
    $row['id'] = (int) $row['id'];
    $row['staff_user_id'] = $row['staff_user_id'] !== null ? (int) $row['staff_user_id'] : null;
    $row['old_values'] = $row['old_values_json'] !== null ? json_decode((string) $row['old_values_json'], true) : null;
    $row['new_values'] = $row['new_values_json'] !== null ? json_decode((string) $row['new_values_json'], true) : null;
    unset($row['old_values_json'], $row['new_values_json']);
    return $row;
}, $stmt->fetchAll());

jsonResponse([
    'ok'    => true,
    'count' => count($logs),
    'logs'  => $logs,
]);
