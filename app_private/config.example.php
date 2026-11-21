<?php
declare(strict_types=1);

/**
 * O ESPANHOL (oespanhol.com.br) — Configuração Privada (Modelo)
 *
 * Em produção na KingHost:
 * 1. Mantenha a pasta `app_private/` FORA de `www/` ou `public_html/` (ideal),
 *    ou protegida pelo `app_private/.htaccess`.
 * 2. Copie este arquivo para `app_private/config.local.php` (ignorado pelo Git)
 *    OU defina as variáveis de ambiente no servidor.
 * 3. NUNCA versione `config.local.php` nem `.env` com senhas reais.
 */

$env = static function (string $key, mixed $default = null): mixed {
    $value = getenv($key);
    if ($value !== false && $value !== '') {
        return $value;
    }
    if (isset($_ENV[$key]) && $_ENV[$key] !== '') {
        return $_ENV[$key];
    }
    return $default;
};

return [
    'app' => [
        'env'      => (string) $env('APP_ENV', 'development'),
        'url'      => (string) $env('APP_URL', 'https://oespanhol.com.br'),
        'timezone' => (string) $env('APP_TIMEZONE', 'America/Sao_Paulo'),
        'debug'    => (string) $env('APP_ENV', 'development') !== 'production',
    ],

    'db' => [
        'host'          => (string) $env('DB_HOST', 'mysql.oespanhol.com.br'),
        'host_fallback' => (string) $env('DB_HOST_FALLBACK', 'mysql50-farm1.kinghost.net'),
        'port'          => (int) $env('DB_PORT', 3306),
        'name'          => (string) $env('DB_NAME', 'oespanhol'),
        'user'          => (string) $env('DB_USER', 'oespanhol'),
        'pass'          => (string) $env('DB_PASS', ''),
        'charset'       => (string) $env('DB_CHARSET', 'utf8mb4'),
        'timeout'       => 5,
    ],

    'security' => [
        'session_name'         => (string) $env('SESSION_NAME', 'oespanhol_staff_sid'),
        'session_idle_timeout' => (int) $env('SESSION_IDLE_TIMEOUT', 1800), // 30 minutos
        'max_failed_attempts'  => (int) $env('AUTH_MAX_FAILED_ATTEMPTS', 5),
        'lock_minutes'         => (int) $env('AUTH_LOCK_MINUTES', 15),
        'csrf_secret'          => (string) $env('CSRF_SECRET', 'CHANGE_ME_LOCAL_ONLY'),
        'cookie_secure'        => ((string) $env('APP_ENV', 'development')) === 'production',
        'cookie_samesite'      => 'Lax',
        'trust_proxy_headers'  => true,
    ],

    'payment' => [
        'provider'       => (string) $env('PAYMENT_PROVIDER', 'asaas'),
        'api_key'        => (string) $env('PAYMENT_API_KEY', ''),
        'webhook_secret' => (string) $env('PAYMENT_WEBHOOK_SECRET', ''),
    ],
];
