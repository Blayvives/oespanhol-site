<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/_init.php';
requireHttpMethod(['POST']);

// Valida CSRF se houver sessão ativa
if (Rbac::currentUser() !== null) {
    Rbac::requireValidCsrf();
}

Rbac::logout();
jsonResponse(['ok' => true, 'message' => 'Sessão encerrada com segurança.']);
