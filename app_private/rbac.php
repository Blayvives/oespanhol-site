<?php
declare(strict_types=1);

/**
 * O ESPANHOL (oespanhol.com.br) — Autenticação, RBAC, Máquina de Estados e Auditoria
 *
 * Papéis suportados:
 *  - ADMIN              : Direção / gestão geral, empregados, catálogo, zonas, auditoria
 *  - GERENTE_OP         : Operação diária, pedidos, cancelamentos/estornos, estoque, assinaturas
 *  - CONCIERGE          : Atendimento, clientes, pedidos assistidos, Clube La Mesa e Embaixadas
 *  - COZINHA_CORTE      : Fila de preparo/fatiamento na faca (PAGO -> EM_PREPARO -> PRONTO_EXPEDICAO)
 *  - LOGISTICA_ENTREGA  : Rotas refrigeradas no DF (PRONTO_EXPEDICAO -> SAIU_PARA_ENTREGA -> ENTREGUE)
 */

require_once __DIR__ . '/db.php';

final class Rbac
{
    public const ROLES = [
        'ADMIN',
        'GERENTE_OP',
        'CONCIERGE',
        'COZINHA_CORTE',
        'LOGISTICA_ENTREGA',
    ];

    /** @var array<string, list<string>> */
    private const ROLE_PERMISSIONS = [
        'ADMIN' => [
            'orders.read',
            'orders.create_assisted',
            'orders.update_status',
            'orders.cancel',
            'orders.refund',
            'customers.read',
            'catalog.read',
            'catalog.write',
            'stock.adjust_loss',
            'zones.write',
            'routes.write',
            'subscriptions.manage',
            'inquiries.manage',
            'reports.read',
            'staff.manage',
            'audit.read',
        ],
        'GERENTE_OP' => [
            'orders.read',
            'orders.create_assisted',
            'orders.update_status',
            'orders.cancel',
            'orders.refund',
            'customers.read',
            'catalog.read',
            'catalog.write',
            'stock.adjust_loss',
            'subscriptions.manage',
            'inquiries.manage',
            'reports.read',
        ],
        'CONCIERGE' => [
            'orders.read',
            'orders.create_assisted',
            'orders.cancel_unpaid',
            'customers.read',
            'catalog.read',
            'subscriptions.manage',
            'inquiries.manage',
        ],
        'COZINHA_CORTE' => [
            'orders.read_kitchen',
            'orders.update_status',
            'catalog.read',
            'stock.adjust_loss',
        ],
        'LOGISTICA_ENTREGA' => [
            'orders.read_delivery',
            'orders.update_status',
        ],
    ];

    /**
     * Máquina de estados de pedidos restrita por papel.
     *
     * @var array<string, array<string, list<string>>>
     */
    private const ALLOWED_TRANSITIONS = [
        'COZINHA_CORTE' => [
            'PAGO'       => ['EM_PREPARO'],
            'EM_PREPARO' => ['PRONTO_EXPEDICAO'],
        ],
        'LOGISTICA_ENTREGA' => [
            'PRONTO_EXPEDICAO'  => ['SAIU_PARA_ENTREGA'],
            'SAIU_PARA_ENTREGA' => ['ENTREGUE'],
        ],
        'CONCIERGE' => [
            'PENDENTE_PAGAMENTO' => ['CANCELADO'],
        ],
        'GERENTE_OP' => [
            'PENDENTE_PAGAMENTO' => ['PAGO', 'CANCELADO'],
            'PAGO'               => ['EM_PREPARO', 'CANCELADO', 'ESTORNADO'],
            'EM_PREPARO'         => ['PRONTO_EXPEDICAO', 'CANCELADO', 'ESTORNADO'],
            'PRONTO_EXPEDICAO'   => ['SAIU_PARA_ENTREGA', 'CANCELADO', 'ESTORNADO'],
            'SAIU_PARA_ENTREGA'  => ['ENTREGUE', 'CANCELADO', 'ESTORNADO'],
            'ENTREGUE'           => ['ESTORNADO'],
        ],
        'ADMIN' => [
            'PENDENTE_PAGAMENTO' => ['PAGO', 'CANCELADO'],
            'PAGO'               => ['EM_PREPARO', 'CANCELADO', 'ESTORNADO'],
            'EM_PREPARO'         => ['PRONTO_EXPEDICAO', 'CANCELADO', 'ESTORNADO'],
            'PRONTO_EXPEDICAO'   => ['SAIU_PARA_ENTREGA', 'CANCELADO', 'ESTORNADO'],
            'SAIU_PARA_ENTREGA'  => ['ENTREGUE', 'CANCELADO', 'ESTORNADO'],
            'ENTREGUE'           => ['ESTORNADO'],
        ],
    ];

    /** @var list<string> */
    private const SENSITIVE_KEYS = [
        'password',
        'password_hash',
        'pass',
        'token',
        'secret',
        'api_key',
        'csrf_token',
        'cpf',
        'card_number',
        'cvv',
    ];

    /**
     * Inicia sessão PHP segura para o backoffice.
     */
    public static function startSession(): void
    {
        if (session_status() === PHP_SESSION_ACTIVE) {
            return;
        }

        $sec = AppConfig::get('security', []);
        $sessionName = (string) ($sec['session_name'] ?? 'oespanhol_staff_sid');
        $isHttps = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
            || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https');
        $cookieSecure = (bool) ($sec['cookie_secure'] ?? false) || $isHttps;
        $sameSite = (string) ($sec['cookie_samesite'] ?? 'Lax');

        ini_set('session.use_strict_mode', '1');
        ini_set('session.use_only_cookies', '1');
        session_name($sessionName);
        session_set_cookie_params([
            'lifetime' => 0,
            'path'     => '/',
            'domain'   => '',
            'secure'   => $cookieSecure,
            'httponly' => true,
            'samesite' => $sameSite,
        ]);

        session_start();
    }

    /**
     * Gera hash seguro de senha (Argon2id preferencial, fallback bcrypt custo 12).
     */
    public static function hashPassword(string $plainPassword): string
    {
        if (defined('PASSWORD_ARGON2ID')) {
            return password_hash($plainPassword, PASSWORD_ARGON2ID);
        }
        return password_hash($plainPassword, PASSWORD_BCRYPT, ['cost' => 12]);
    }

    /**
     * Autentica empregado com proteção contra força bruta e auditoria obrigatória.
     *
     * @return array{ok: bool, status: int, error?: string, user?: array<string, mixed>, csrf_token?: string}
     */
    public static function login(string $email, string $password): array
    {
        self::startSession();
        $pdo = Database::connection();

        $normalizedEmail = mb_strtolower(trim($email), 'UTF-8');
        if ($normalizedEmail === '' || $password === '') {
            return ['ok' => false, 'status' => 400, 'error' => 'Informe e-mail e senha.'];
        }

        $stmt = $pdo->prepare(
            'SELECT id, full_name, email, password_hash, role, is_active, failed_attempts, locked_until, password_changed_at
               FROM staff_users
              WHERE email = :email
              LIMIT 1'
        );
        $stmt->execute([':email' => $normalizedEmail]);
        $user = $stmt->fetch();

        if (!$user) {
            self::auditLog(null, 'AUTH_LOGIN_FAILED', 'staff_user', null, null, ['email' => $normalizedEmail, 'reason' => 'not_found']);
            return ['ok' => false, 'status' => 401, 'error' => 'Credenciais inválidas.'];
        }

        if ((int) $user['is_active'] !== 1) {
            self::auditLog((int) $user['id'], 'AUTH_LOGIN_BLOCKED', 'staff_user', (string) $user['id'], null, ['reason' => 'inactive']);
            return ['ok' => false, 'status' => 403, 'error' => 'Conta corporativa desativada. Contate a administração.'];
        }

        if (!empty($user['locked_until']) && strtotime((string) $user['locked_until']) > time()) {
            self::auditLog((int) $user['id'], 'AUTH_LOGIN_LOCKED', 'staff_user', (string) $user['id'], null, ['locked_until' => $user['locked_until']]);
            return ['ok' => false, 'status' => 429, 'error' => 'Conta temporariamente bloqueada por excesso de tentativas. Aguarde alguns minutos.'];
        }

        $maxAttempts = (int) AppConfig::get('security.max_failed_attempts', 5);
        $lockMinutes = (int) AppConfig::get('security.lock_minutes', 15);

        if (!password_verify($password, (string) $user['password_hash'])) {
            $attempts = ((int) $user['failed_attempts']) + 1;
            $lockedUntil = $attempts >= $maxAttempts
                ? date('Y-m-d H:i:s', time() + ($lockMinutes * 60))
                : null;

            $upd = $pdo->prepare(
                'UPDATE staff_users
                    SET failed_attempts = :attempts,
                        locked_until = :locked_until
                  WHERE id = :id'
            );
            $upd->execute([
                ':attempts'     => $attempts,
                ':locked_until' => $lockedUntil,
                ':id'           => $user['id'],
            ]);

            self::auditLog((int) $user['id'], 'AUTH_LOGIN_FAILED', 'staff_user', (string) $user['id'], null, [
                'failed_attempts' => $attempts,
                'locked'          => $lockedUntil !== null,
            ]);

            return ['ok' => false, 'status' => 401, 'error' => 'Credenciais inválidas.'];
        }

        // Sucesso: zera contadores, atualiza last_login_at e regenera ID de sessão
        $upd = $pdo->prepare(
            'UPDATE staff_users
                SET failed_attempts = 0,
                    locked_until = NULL,
                    last_login_at = NOW()
              WHERE id = :id'
        );
        $upd->execute([':id' => $user['id']]);

        session_regenerate_id(true);
        $_SESSION['staff_id'] = (int) $user['id'];
        $_SESSION['staff_role'] = (string) $user['role'];
        $_SESSION['pwd_changed_at'] = (string) $user['password_changed_at'];
        $_SESSION['last_activity'] = time();
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));

        self::auditLog((int) $user['id'], 'AUTH_LOGIN_SUCCESS', 'staff_user', (string) $user['id'], null, ['role' => $user['role']]);

        return [
            'ok'         => true,
            'status'     => 200,
            'csrf_token' => $_SESSION['csrf_token'],
            'user'       => [
                'id'          => (int) $user['id'],
                'full_name'   => (string) $user['full_name'],
                'email'       => (string) $user['email'],
                'role'        => (string) $user['role'],
                'permissions' => self::permissionsForRole((string) $user['role']),
            ],
        ];
    }

    /**
     * Encerra sessão ativa com registro de auditoria.
     */
    public static function logout(): void
    {
        self::startSession();
        $staffId = isset($_SESSION['staff_id']) ? (int) $_SESSION['staff_id'] : null;

        if ($staffId !== null) {
            self::auditLog($staffId, 'AUTH_LOGOUT', 'staff_user', (string) $staffId, null, null);
        }

        $_SESSION = [];
        if (ini_get('session.use_cookies')) {
            $params = session_get_cookie_params();
            setcookie(
                session_name(),
                '',
                time() - 42000,
                $params['path'],
                $params['domain'],
                (bool) $params['secure'],
                (bool) $params['httponly']
            );
        }
        session_destroy();
    }

    /**
     * Retorna o empregado autenticado validando timeout de inatividade, status ativo e troca de senha.
     *
     * @return array<string, mixed>|null
     */
    public static function currentUser(): ?array
    {
        self::startSession();
        if (empty($_SESSION['staff_id'])) {
            return null;
        }

        $idleTimeout = (int) AppConfig::get('security.session_idle_timeout', 1800);
        $lastActivity = (int) ($_SESSION['last_activity'] ?? 0);
        if ($lastActivity > 0 && (time() - $lastActivity) > $idleTimeout) {
            self::logout();
            return null;
        }

        $pdo = Database::connection();
        $stmt = $pdo->prepare(
            'SELECT id, full_name, email, role, is_active, password_changed_at
               FROM staff_users
              WHERE id = :id
              LIMIT 1'
        );
        $stmt->execute([':id' => (int) $_SESSION['staff_id']]);
        $user = $stmt->fetch();

        if (
            !$user ||
            (int) $user['is_active'] !== 1 ||
            (string) $user['password_changed_at'] !== (string) ($_SESSION['pwd_changed_at'] ?? '')
        ) {
            self::logout();
            return null;
        }

        $_SESSION['last_activity'] = time();
        $_SESSION['staff_role'] = (string) $user['role'];

        return [
            'id'          => (int) $user['id'],
            'full_name'   => (string) $user['full_name'],
            'email'       => (string) $user['email'],
            'role'        => (string) $user['role'],
            'permissions' => self::permissionsForRole((string) $user['role']),
        ];
    }

    /**
     * Exige autenticação ativa e (opcionalmente) uma permissão específica.
     *
     * @return array<string, mixed>
     */
    public static function requireAuth(?string $permission = null, bool $requireCsrfOnWrite = true): array
    {
        $user = self::currentUser();
        if ($user === null) {
            jsonResponse(['error' => 'Sessão expirada ou não autenticada.'], 401);
        }

        $method = strtoupper((string) ($_SERVER['REQUEST_METHOD'] ?? 'GET'));
        if ($requireCsrfOnWrite && in_array($method, ['POST', 'PUT', 'PATCH', 'DELETE'], true)) {
            self::requireValidCsrf();
        }

        if ($permission !== null && !self::hasPermission((string) $user['role'], $permission)) {
            self::auditLog(
                (int) $user['id'],
                'RBAC_ACCESS_DENIED',
                'permission',
                $permission,
                null,
                ['role' => $user['role'], 'method' => $method, 'uri' => $_SERVER['REQUEST_URI'] ?? '']
            );
            jsonResponse(['error' => 'Acesso negado para o seu perfil operacional.'], 403);
        }

        return $user;
    }

    /**
     * Valida token CSRF enviado no header X-CSRF-Token.
     */
    public static function requireValidCsrf(): void
    {
        self::startSession();
        $expected = (string) ($_SESSION['csrf_token'] ?? '');
        $provided = (string) ($_SERVER['HTTP_X_CSRF_TOKEN'] ?? '');

        if ($expected === '' || $provided === '' || !hash_equals($expected, $provided)) {
            jsonResponse(['error' => 'Token CSRF inválido ou ausente.'], 403);
        }
    }

    public static function csrfToken(): string
    {
        self::startSession();
        if (empty($_SESSION['csrf_token'])) {
            $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        }
        return (string) $_SESSION['csrf_token'];
    }

    /**
     * @return list<string>
     */
    public static function permissionsForRole(string $role): array
    {
        return self::ROLE_PERMISSIONS[$role] ?? [];
    }

    public static function hasPermission(string $role, string $permission): bool
    {
        return in_array($permission, self::permissionsForRole($role), true);
    }

    /**
     * Valida se o papel pode mover um pedido de $fromStatus para $toStatus.
     */
    public static function canTransitionOrderStatus(string $role, string $fromStatus, string $toStatus): bool
    {
        $allowedNext = self::ALLOWED_TRANSITIONS[$role][$fromStatus] ?? [];
        return in_array($toStatus, $allowedNext, true);
    }

    /**
     * Impede desativar ou rebaixar o último ADMIN ativo do sistema.
     */
    public static function ensureNotLastActiveAdmin(PDO $pdo, int $targetStaffId): void
    {
        $stmt = $pdo->prepare(
            "SELECT COUNT(*) AS cnt
               FROM staff_users
              WHERE role = 'ADMIN'
                AND is_active = 1
                AND id <> :target_id"
        );
        $stmt->execute([':target_id' => $targetStaffId]);
        $otherAdmins = (int) ($stmt->fetch()['cnt'] ?? 0);

        if ($otherAdmins < 1) {
            jsonResponse([
                'error' => 'Operação bloqueada: o sistema deve manter ao menos 1 administrador (ADMIN) ativo.',
            ], 409);
        }
    }

    /**
     * Registra evento imutável em audit_logs mascarando campos sensíveis.
     *
     * @param array<string, mixed>|null $oldValues
     * @param array<string, mixed>|null $newValues
     */
    public static function auditLog(
        ?int $staffUserId,
        string $action,
        string $entityType,
        ?string $entityId,
        ?array $oldValues = null,
        ?array $newValues = null
    ): void {
        try {
            $pdo = Database::connection();
            $stmt = $pdo->prepare(
                'INSERT INTO audit_logs
                    (staff_user_id, action, entity_type, entity_id, old_values_json, new_values_json, ip_address, user_agent)
                 VALUES
                    (:staff_user_id, :action, :entity_type, :entity_id, :old_json, :new_json, :ip_address, :user_agent)'
            );

            $stmt->execute([
                ':staff_user_id' => $staffUserId,
                ':action'        => substr($action, 0, 80),
                ':entity_type'   => substr($entityType, 0, 60),
                ':entity_id'     => $entityId !== null ? substr($entityId, 0, 64) : null,
                ':old_json'      => $oldValues !== null ? json_encode(self::scrubSensitive($oldValues), JSON_UNESCAPED_UNICODE) : null,
                ':new_json'      => $newValues !== null ? json_encode(self::scrubSensitive($newValues), JSON_UNESCAPED_UNICODE) : null,
                ':ip_address'    => self::clientIp(),
                ':user_agent'    => substr((string) ($_SERVER['HTTP_USER_AGENT'] ?? ''), 0, 255) ?: null,
            ]);
        } catch (Throwable) {
            // Evita vazamento de stack trace caso auditoria falhe em cenário de indisponibilidade do banco
            error_log("[OESPANHOL][AUDIT_ERROR] Falha ao gravar audit_logs para ação {$action}");
        }
    }

    /**
     * @param array<string, mixed> $data
     * @return array<string, mixed>
     */
    private static function scrubSensitive(array $data): array
    {
        $clean = [];
        foreach ($data as $key => $value) {
            $lower = strtolower((string) $key);
            if (in_array($lower, self::SENSITIVE_KEYS, true)) {
                $clean[$key] = '[REDACTED]';
            } elseif (is_array($value)) {
                $clean[$key] = self::scrubSensitive($value);
            } else {
                $clean[$key] = $value;
            }
        }
        return $clean;
    }

    public static function clientIp(): string
    {
        if ((bool) AppConfig::get('security.trust_proxy_headers', true)) {
            $forwarded = (string) ($_SERVER['HTTP_X_FORWARDED_FOR'] ?? '');
            if ($forwarded !== '') {
                $first = trim(explode(',', $forwarded)[0]);
                if (filter_var($first, FILTER_VALIDATE_IP)) {
                    return $first;
                }
            }
        }
        $remote = (string) ($_SERVER['REMOTE_ADDR'] ?? '0.0.0.0');
        return filter_var($remote, FILTER_VALIDATE_IP) ? $remote : '0.0.0.0';
    }
}
