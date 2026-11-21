<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/_init.php';
$method = requireHttpMethod(['GET', 'POST', 'PATCH']);
$pdo = Database::connection();

// -----------------------------------------------------------------------------
// POST — Envio público de solicitação de Presentes Corporativos / Embaixadas
// -----------------------------------------------------------------------------
if ($method === 'POST') {
    $body = readJsonBody();
    $org = trim((string) ($body['organization_name'] ?? ''));
    $contact = trim((string) ($body['contact_name'] ?? ''));
    $email = mb_strtolower(trim((string) ($body['email'] ?? '')), 'UTF-8');
    $phone = trim((string) ($body['phone'] ?? ''));
    $qty = max(1, (int) ($body['box_quantity'] ?? 6));
    $regions = trim((string) ($body['preferred_regions'] ?? '')) ?: null;
    $eventDate = trim((string) ($body['event_date'] ?? '')) ?: null;
    $needsCarver = !empty($body['needs_jamon_carver']) ? 1 : 0;
    $notes = trim((string) ($body['notes'] ?? '')) ?: null;

    if ($org === '' || $contact === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen(preg_replace('/\D+/', '', $phone)) < 10) {
        jsonResponse(['error' => 'Informe instituição/empresa, nome do contato, e-mail válido e telefone.'], 400);
    }

    if ($eventDate !== null && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $eventDate)) {
        jsonResponse(['error' => 'Formato de event_date inválido (use YYYY-MM-DD).'], 400);
    }

    $stmt = $pdo->prepare(
        'INSERT INTO corporate_inquiries
            (organization_name, contact_name, email, phone, box_quantity, preferred_regions, event_date, needs_jamon_carver, notes, status)
         VALUES
            (:org, :contact, :email, :phone, :qty, :regions, :edate, :carver, :notes, "NOVO")'
    );
    $stmt->execute([
        ':org'     => substr($org, 0, 180),
        ':contact' => substr($contact, 0, 160),
        ':email'   => substr($email, 0, 190),
        ':phone'   => substr($phone, 0, 32),
        ':qty'     => $qty,
        ':regions' => $regions !== null ? substr($regions, 0, 255) : null,
        ':edate'   => $eventDate,
        ':carver'  => $needsCarver,
        ':notes'   => $notes,
    ]);

    jsonResponse([
        'ok'         => true,
        'inquiry_id' => (int) $pdo->lastInsertId(),
        'message'    => 'Solicitação registrada com sucesso. Nosso Concierge entrará em contato.',
    ], 201);
}

// -----------------------------------------------------------------------------
// GET / PATCH — Atendimento interno (CONCIERGE, GERENTE_OP, ADMIN)
// -----------------------------------------------------------------------------
$staff = Rbac::requireAuth('inquiries.manage', $method !== 'GET');

if ($method === 'GET') {
    $where = ['1 = 1'];
    $params = [];
    if (!empty($_GET['status'])) {
        $where[] = 'ci.status = :st';
        $params[':st'] = strtoupper(trim((string) $_GET['status']));
    }

    $stmt = $pdo->prepare(
        'SELECT ci.*, su.full_name AS assigned_staff_name
           FROM corporate_inquiries ci
           LEFT JOIN staff_users su ON su.id = ci.assigned_staff_id
          WHERE ' . implode(' AND ', $where) . '
          ORDER BY ci.created_at DESC
          LIMIT 100'
    );
    $stmt->execute($params);
    jsonResponse(['ok' => true, 'inquiries' => $stmt->fetchAll()]);
}

$body = readJsonBody();
$inquiryId = (int) ($body['id'] ?? 0);
$newStatus = strtoupper(trim((string) ($body['status'] ?? '')));
$validStatuses = ['NOVO', 'EM_ATENDIMENTO', 'PROPOSTA_ENVIADA', 'FECHADO', 'CANCELADO'];

if ($inquiryId <= 0 || !in_array($newStatus, $validStatuses, true)) {
    jsonResponse(['error' => 'Informe id e status válido para a solicitação corporativa.'], 400);
}

$curStmt = $pdo->prepare('SELECT id, status, assigned_staff_id, notes FROM corporate_inquiries WHERE id = :id LIMIT 1');
$curStmt->execute([':id' => $inquiryId]);
$current = $curStmt->fetch();
if (!$current) {
    jsonResponse(['error' => 'Solicitação corporativa não encontrada.'], 404);
}

$notes = array_key_exists('notes', $body) ? trim((string) $body['notes']) : $current['notes'];
$pdo->prepare(
    'UPDATE corporate_inquiries
        SET status = :st,
            assigned_staff_id = :sid,
            notes = :notes
      WHERE id = :id'
)->execute([
    ':st'    => $newStatus,
    ':sid'   => (int) $staff['id'],
    ':notes' => $notes,
    ':id'    => $inquiryId,
]);

Rbac::auditLog((int) $staff['id'], 'CORPORATE_INQUIRY_UPDATED', 'corporate_inquiry', (string) $inquiryId, $current, [
    'status' => $newStatus,
    'assigned_staff_id' => (int) $staff['id'],
]);

jsonResponse(['ok' => true, 'id' => $inquiryId, 'status' => $newStatus]);
