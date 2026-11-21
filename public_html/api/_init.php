<?php
declare(strict_types=1);

/**
 * Localiza app_private/bootstrap.php tanto na estrutura do repositório
 * quanto na implantação KingHost (app_private fora de www/public_html).
 */

$candidates = [
    dirname(__DIR__, 2) . '/app_private/bootstrap.php', // repo: oespanhol-site/app_private/
    dirname(__DIR__, 3) . '/app_private/bootstrap.php', // hospedagem com nível extra
    __DIR__ . '/app_private/bootstrap.php',
];

$bootstrapPath = null;
foreach ($candidates as $path) {
    if (is_file($path)) {
        $bootstrapPath = $path;
        break;
    }
}

if ($bootstrapPath === null) {
    http_response_code(500);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['error' => 'Configuração privada (app_private) não encontrada no servidor.']);
    exit;
}

require_once $bootstrapPath;
