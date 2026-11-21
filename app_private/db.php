<?php
declare(strict_types=1);

/**
 * O ESPANHOL (oespanhol.com.br) — Camada de Configuração e Conexão PDO (MySQL 11.4)
 */

final class AppConfig
{
    /** @var array<string, mixed>|null */
    private static ?array $cache = null;

    /**
     * Carrega .env (se existir na raiz do projeto) sem sobrescrever variáveis já definidas no servidor.
     */
    private static function loadDotEnvIfPresent(): void
    {
        $envPath = dirname(__DIR__) . DIRECTORY_SEPARATOR . '.env';
        if (!is_file($envPath) || !is_readable($envPath)) {
            return;
        }

        $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        if ($lines === false) {
            return;
        }

        foreach ($lines as $line) {
            $trimmed = trim($line);
            if ($trimmed === '' || str_starts_with($trimmed, '#')) {
                continue;
            }
            $pos = strpos($trimmed, '=');
            if ($pos === false) {
                continue;
            }
            $key = trim(substr($trimmed, 0, $pos));
            $val = trim(substr($trimmed, $pos + 1));
            if (
                (str_starts_with($val, '"') && str_ends_with($val, '"')) ||
                (str_starts_with($val, "'") && str_ends_with($val, "'"))
            ) {
                $val = substr($val, 1, -1);
            }
            if ($key !== '' && getenv($key) === false && !isset($_ENV[$key])) {
                putenv("{$key}={$val}");
                $_ENV[$key] = $val;
            }
        }
    }

    /**
     * @return array<string, mixed>
     */
    public static function all(): array
    {
        if (self::$cache !== null) {
            return self::$cache;
        }

        self::loadDotEnvIfPresent();

        $localConfig = __DIR__ . DIRECTORY_SEPARATOR . 'config.local.php';
        $exampleConfig = __DIR__ . DIRECTORY_SEPARATOR . 'config.example.php';

        /** @var array<string, mixed> $config */
        $config = is_file($localConfig)
            ? require $localConfig
            : require $exampleConfig;

        $tz = (string) ($config['app']['timezone'] ?? 'America/Sao_Paulo');
        date_default_timezone_set($tz);

        self::$cache = $config;
        return self::$cache;
    }

    public static function get(string $path, mixed $default = null): mixed
    {
        $cursor = self::all();
        foreach (explode('.', $path) as $segment) {
            if (!is_array($cursor) || !array_key_exists($segment, $cursor)) {
                return $default;
            }
            $cursor = $cursor[$segment];
        }
        return $cursor;
    }
}

final class Database
{
    private static ?PDO $pdo = null;

    /**
     * Retorna conexão PDO singleton com MySQL 11.4 (utf8mb4, prepared statements nativos)
     * e failover automático para o host alternativo da KingHost.
     */
    public static function connection(): PDO
    {
        if (self::$pdo instanceof PDO) {
            return self::$pdo;
        }

        $db = AppConfig::get('db', []);
        $primaryHost = (string) ($db['host'] ?? 'mysql.oespanhol.com.br');
        $fallbackHost = (string) ($db['host_fallback'] ?? '');
        $port = (int) ($db['port'] ?? 3306);
        $name = (string) ($db['name'] ?? 'oespanhol');
        $user = (string) ($db['user'] ?? '');
        $pass = (string) ($db['pass'] ?? '');
        $charset = (string) ($db['charset'] ?? 'utf8mb4');
        $timeout = (int) ($db['timeout'] ?? 5);

        $hosts = array_values(array_unique(array_filter([$primaryHost, $fallbackHost])));
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
            PDO::ATTR_TIMEOUT            => $timeout,
        ];

        if (defined('PDO::MYSQL_ATTR_INIT_COMMAND')) {
            $options[PDO::MYSQL_ATTR_INIT_COMMAND] = "SET NAMES {$charset} COLLATE utf8mb4_unicode_ci, time_zone = '-03:00'";
        }

        $lastException = null;
        foreach ($hosts as $host) {
            $dsn = sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s', $host, $port, $name, $charset);
            try {
                self::$pdo = new PDO($dsn, $user, $pass, $options);
                return self::$pdo;
            } catch (PDOException $e) {
                $lastException = $e;
            }
        }

        throw new RuntimeException(
            'Não foi possível conectar ao banco MySQL do O Espanhol.',
            0,
            $lastException
        );
    }

    /**
     * Executa uma função dentro de uma transação SQL segura (BEGIN / COMMIT / ROLLBACK).
     *
     * @template T
     * @param callable(PDO): T $callback
     * @return T
     */
    public static function transaction(callable $callback): mixed
    {
        $pdo = self::connection();
        $startedHere = !$pdo->inTransaction();

        if ($startedHere) {
            $pdo->beginTransaction();
        }

        try {
            $result = $callback($pdo);
            if ($startedHere && $pdo->inTransaction()) {
                $pdo->commit();
            }
            return $result;
        } catch (Throwable $e) {
            if ($startedHere && $pdo->inTransaction()) {
                $pdo->rollBack();
            }
            throw $e;
        }
    }
}

/**
 * Resposta JSON padronizada para endpoints REST em UTF-8.
 *
 * @param array<string, mixed> $payload
 */
function jsonResponse(array $payload, int $statusCode = 200): never
{
    if (!headers_sent()) {
        http_response_code($statusCode);
        header('Content-Type: application/json; charset=utf-8');
        header('X-Content-Type-Options: nosniff');
        header('Cache-Control: no-store, no-cache, must-revalidate');
    }

    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

/**
 * Lê corpo JSON da requisição com limite de tamanho e validação.
 *
 * @return array<string, mixed>
 */
function readJsonBody(int $maxBytes = 1048576): array
{
    $raw = file_get_contents('php://input', false, null, 0, $maxBytes + 1);
    if ($raw === false || trim($raw) === '') {
        return [];
    }
    if (strlen($raw) > $maxBytes) {
        jsonResponse(['error' => 'Payload excede o limite permitido.'], 413);
    }

    $decoded = json_decode($raw, true);
    if (!is_array($decoded)) {
        jsonResponse(['error' => 'Corpo JSON inválido.'], 400);
    }
    return $decoded;
}
