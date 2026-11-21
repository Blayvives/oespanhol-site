<?php
declare(strict_types=1);

/**
 * O ESPANHOL (oespanhol.com.br) — Bootstrap Privado da API
 */

require_once __DIR__ . '/db.php';
require_once __DIR__ . '/rbac.php';
require_once __DIR__ . '/services/PricingService.php';
require_once __DIR__ . '/services/PaymentService.php';
require_once __DIR__ . '/services/OrderService.php';

AppConfig::all();

// Cabeçalhos de segurança padrão para respostas da API
if (!headers_sent()) {
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: DENY');
    header('Referrer-Policy: strict-origin-when-cross-origin');
}

// Tratamento centralizado de exceções sem vazar credenciais ou stack traces em produção
set_exception_handler(static function (Throwable $e): void {
    $debug = (bool) AppConfig::get('app.debug', false);
    error_log(sprintf('[OESPANHOL][UNCAUGHT] %s in %s:%d', $e->getMessage(), $e->getFile(), $e->getLine()));

    $payload = ['error' => 'Erro interno ao processar a solicitação.'];
    if ($debug) {
        $payload['detail'] = $e->getMessage();
    }
    jsonResponse($payload, 500);
});

/**
 * Garante método HTTP permitido; responde 405 caso contrário.
 *
 * @param list<string> $allowed
 */
function requireHttpMethod(array $allowed): string
{
    $method = strtoupper((string) ($_SERVER['REQUEST_METHOD'] ?? 'GET'));
    if ($method === 'OPTIONS') {
        http_response_code(204);
        exit;
    }
    if (!in_array($method, $allowed, true)) {
        header('Allow: ' . implode(', ', $allowed));
        jsonResponse(['error' => 'Método HTTP não permitido.'], 405);
    }
    return $method;
}
