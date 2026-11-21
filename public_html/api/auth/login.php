<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/_init.php';
requireHttpMethod(['POST']);

$body = readJsonBody();
$email = (string) ($body['email'] ?? '');
$password = (string) ($body['password'] ?? '');

$result = Rbac::login($email, $password);
if (!$result['ok']) {
    jsonResponse(['error' => $result['error'] ?? 'Falha na autenticação.'], (int) $result['status']);
}

jsonResponse([
    'ok'         => true,
    'csrf_token' => $result['csrf_token'],
    'user'       => $result['user'],
]);
