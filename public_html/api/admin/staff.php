<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/_init.php';
$method = requireHttpMethod(['GET', 'POST', 'PATCH']);

// Exclusivo para ADMIN (staff.manage)
$admin = Rbac::requireAuth('staff.manage', $method !== 'GET');
$pdo = Database::connection();

if ($method === 'GET') {
    $rows = $pdo->query(
        'SELECT id, full_name, email, role, is_active, failed_attempts, locked_until, last_login_at, created_at
           FROM staff_users
          ORDER BY is_active DESC, role ASC, full_name ASC'
    )->fetchAll();

    jsonResponse([
        'ok'    => true,
        'staff' => array_map(static function (array $u): array {
            $u['id'] = (int) $u['id'];
            $u['is_active'] = (int) $u['is_active'] === 1;
            $u['failed_attempts'] = (int) $u['failed_attempts'];
            return $u;
        }, $rows),
    ]);
}

$body = readJsonBody();

if ($method === 'POST') {
    $fullName = trim((string) ($body['full_name'] ?? ''));
    $email = mb_strtolower(trim((string) ($body['email'] ?? '')), 'UTF-8');
    $password = (string) ($body['password'] ?? '');
    $role = strtoupper(trim((string) ($body['role'] ?? '')));

    if ($fullName === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($password) < 10) {
        jsonResponse(['error' => 'Informe nome completo, e-mail válido e senha com ao menos 10 caracteres.'], 400);
    }
    if (!in_array($role, Rbac::ROLES, true)) {
        jsonResponse(['error' => 'Papel (role) inválido.'], 400);
    }

    $hash = Rbac::hashPassword($password);
    try {
        $stmt = $pdo->prepare(
            'INSERT INTO staff_users (full_name, email, password_hash, role, is_active)
             VALUES (:name, :email, :hash, :role, 1)'
        );
        $stmt->execute([
            ':name'  => $fullName,
            ':email' => $email,
            ':hash'  => $hash,
            ':role'  => $role,
        ]);
    } catch (PDOException $e) {
        if ((string) $e->getCode() === '23000') {
            jsonResponse(['error' => 'Já existe um empregado cadastrado com este e-mail.'], 409);
        }
        throw $e;
    }

    $newId = (int) $pdo->lastInsertId();
    Rbac::auditLog((int) $admin['id'], 'STAFF_CREATED', 'staff_user', (string) $newId, null, [
        'full_name' => $fullName,
        'email'     => $email,
        'role'      => $role,
    ]);

    jsonResponse(['ok' => true, 'id' => $newId, 'email' => $email, 'role' => $role], 201);
}

// PATCH — Atualizar papel, ativar/suspender, desbloquear ou redefinir senha
$targetId = (int) ($body['id'] ?? 0);
if ($targetId <= 0) {
    jsonResponse(['error' => 'Informe o id do empregado.'], 400);
}

$curStmt = $pdo->prepare('SELECT id, full_name, email, role, is_active FROM staff_users WHERE id = :id LIMIT 1');
$curStmt->execute([':id' => $targetId]);
$current = $curStmt->fetch();
if (!$current) {
    jsonResponse(['error' => 'Empregado não encontrado.'], 404);
}

$sets = [];
$params = [':id' => $targetId];
$changes = [];

$newRole = isset($body['role']) ? strtoupper(trim((string) $body['role'])) : (string) $current['role'];
$newActive = array_key_exists('is_active', $body) ? ($body['is_active'] ? 1 : 0) : (int) $current['is_active'];

if (!in_array($newRole, Rbac::ROLES, true)) {
    jsonResponse(['error' => 'Papel inválido.'], 400);
}

// Regra de segurança: nunca deixar o sistema sem pelo menos 1 ADMIN ativo
if ((string) $current['role'] === 'ADMIN' && ($newRole !== 'ADMIN' || $newActive === 0)) {
    Rbac::ensureNotLastActiveAdmin($pdo, $targetId);
}

if (isset($body['full_name']) && trim((string) $body['full_name']) !== '') {
    $sets[] = 'full_name = :full_name';
    $params[':full_name'] = trim((string) $body['full_name']);
    $changes['full_name'] = $params[':full_name'];
}
if ($newRole !== (string) $current['role']) {
    $sets[] = 'role = :role';
    $params[':role'] = $newRole;
    $changes['role'] = $newRole;
}
if ($newActive !== (int) $current['is_active']) {
    $sets[] = 'is_active = :is_active';
    $params[':is_active'] = $newActive;
    $changes['is_active'] = $newActive;
}
if (!empty($body['unlock'])) {
    $sets[] = 'failed_attempts = 0, locked_until = NULL';
    $changes['unlocked'] = true;
}
if (!empty($body['new_password'])) {
    $newPass = (string) $body['new_password'];
    if (strlen($newPass) < 10) {
        jsonResponse(['error' => 'Nova senha deve ter ao menos 10 caracteres.'], 400);
    }
    $sets[] = 'password_hash = :phash, password_changed_at = NOW(), failed_attempts = 0, locked_until = NULL';
    $params[':phash'] = Rbac::hashPassword($newPass);
    $changes['password_reset'] = true;
}

if ($sets === []) {
    jsonResponse(['error' => 'Nenhuma alteração informada.'], 400);
}

$pdo->prepare('UPDATE staff_users SET ' . implode(', ', $sets) . ' WHERE id = :id')->execute($params);

Rbac::auditLog((int) $admin['id'], 'STAFF_UPDATED', 'staff_user', (string) $targetId, $current, $changes);

jsonResponse(['ok' => true, 'id' => $targetId, 'changes' => $changes]);
