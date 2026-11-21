<?php
declare(strict_types=1);

/**
 * O ESPANHOL — PaymentService
 * Registro de cobranças e processamento assinado + idempotente de webhooks de pagamento.
 */

final class PaymentService
{
    public const VALID_METHODS = ['PIX', 'CREDIT_CARD', 'BOLETO', 'OTHER'];

    /**
     * Registra intenção de cobrança para um pedido recém-criado dentro da mesma transação.
     *
     * @return array<string, mixed>
     */
    public static function createPendingPayment(
        PDO $pdo,
        int $orderId,
        string $orderCode,
        int $amountCents,
        string $method = 'PIX'
    ): array {
        $method = strtoupper($method);
        if (!in_array($method, self::VALID_METHODS, true)) {
            $method = 'PIX';
        }

        $provider = (string) AppConfig::get('payment.provider', 'asaas');
        $providerRef = sprintf('%s_%s_%s', $provider, $orderCode, bin2hex(random_bytes(4)));

        $stmt = $pdo->prepare(
            'INSERT INTO payments (order_id, provider, provider_reference, method, amount_cents, status)
             VALUES (:order_id, :provider, :provider_ref, :method, :amount_cents, "PENDING")'
        );
        $stmt->execute([
            ':order_id'     => $orderId,
            ':provider'     => $provider,
            ':provider_ref' => $providerRef,
            ':method'       => $method,
            ':amount_cents' => $amountCents,
        ]);

        return [
            'payment_id'         => (int) $pdo->lastInsertId(),
            'provider'           => $provider,
            'provider_reference' => $providerRef,
            'method'             => $method,
            'amount_cents'       => $amountCents,
            'status'             => 'PENDING',
        ];
    }

    /**
     * Valida assinatura HMAC-SHA256 (ou token de cabeçalho do gateway) contra segredo configurado.
     */
    public static function verifyWebhookSignature(string $rawBody, array $headers): bool
    {
        $secret = (string) AppConfig::get('payment.webhook_secret', '');
        if ($secret === '' || $secret === 'TROQUE_PELO_SEGREDO_HMAC_DO_WEBHOOK') {
            return false;
        }

        $normalized = [];
        foreach ($headers as $k => $v) {
            $normalized[strtolower((string) $k)] = trim((string) $v);
        }

        // Padrão 1: Assinatura HMAC-SHA256 no corpo bruto (X-Webhook-Signature: sha256=<hex> ou <hex>)
        if (!empty($normalized['x-webhook-signature'])) {
            $sig = preg_replace('/^sha256=/i', '', $normalized['x-webhook-signature']);
            $expected = hash_hmac('sha256', $rawBody, $secret);
            return is_string($sig) && hash_equals($expected, $sig);
        }

        // Padrão 2: Token compartilhado (ex.: Asaas asaas-access-token)
        if (!empty($normalized['asaas-access-token'])) {
            return hash_equals($secret, $normalized['asaas-access-token']);
        }

        return false;
    }

    /**
     * Processa webhook de pagamento com idempotência garantida via tabela webhook_events.
     *
     * Payload normalizado esperado:
     * {
     *   "provider": "asaas",
     *   "event_id": "evt_12345",
     *   "event_type": "PAYMENT_CONFIRMED" | "PAYMENT_FAILED" | "PAYMENT_REFUNDED",
     *   "provider_reference": "asaas_ESP-...",
     *   "order_code": "ESP-..." (opcional se provider_reference informado)
     * }
     *
     * @param array<string, string> $headers
     * @return array{status_code: int, body: array<string, mixed>}
     */
    public static function handleWebhook(string $rawBody, array $headers): array
    {
        if (!self::verifyWebhookSignature($rawBody, $headers)) {
            return ['status_code' => 401, 'body' => ['error' => 'Assinatura do webhook inválida.']];
        }

        $payload = json_decode($rawBody, true);
        if (!is_array($payload)) {
            return ['status_code' => 400, 'body' => ['error' => 'Payload JSON inválido.']];
        }

        $provider = trim((string) ($payload['provider'] ?? AppConfig::get('payment.provider', 'asaas')));
        $eventId = trim((string) ($payload['event_id'] ?? $payload['id'] ?? ''));
        $eventType = strtoupper(trim((string) ($payload['event_type'] ?? $payload['event'] ?? '')));
        $providerRef = trim((string) ($payload['provider_reference'] ?? ($payload['payment']['externalReference'] ?? '')));
        $orderCode = trim((string) ($payload['order_code'] ?? ''));

        if ($eventId === '' || ($providerRef === '' && $orderCode === '')) {
            return ['status_code' => 400, 'body' => ['error' => 'Campos obrigatórios ausentes (event_id e referência).']];
        }

        $pdo = Database::connection();

        // 1. Garantia de idempotência pela chave única (provider, event_id)
        try {
            $insEvt = $pdo->prepare(
                'INSERT INTO webhook_events (provider, event_id, payload_json, status)
                 VALUES (:provider, :event_id, :payload_json, "RECEIVED")'
            );
            $insEvt->execute([
                ':provider'     => $provider,
                ':event_id'     => $eventId,
                ':payload_json' => $rawBody,
            ]);
            $webhookRowId = (int) $pdo->lastInsertId();
        } catch (PDOException $e) {
            if ((string) $e->getCode() === '23000') {
                return [
                    'status_code' => 200,
                    'body'        => ['ok' => true, 'status' => 'already_processed', 'event_id' => $eventId],
                ];
            }
            throw $e;
        }

        // 2. Processamento transacional da confirmação/falha/estorno
        try {
            $result = Database::transaction(static function (PDO $tx) use (
                $webhookRowId,
                $eventType,
                $providerRef,
                $orderCode
            ): array {
                if ($providerRef !== '') {
                    $pStmt = $tx->prepare(
                        'SELECT p.id, p.order_id, p.status AS payment_status, o.status AS order_status, o.order_code
                           FROM payments p
                           JOIN orders o ON o.id = p.order_id
                          WHERE p.provider_reference = :ref
                          LIMIT 1
                            FOR UPDATE'
                    );
                    $pStmt->execute([':ref' => $providerRef]);
                } else {
                    $pStmt = $tx->prepare(
                        'SELECT p.id, p.order_id, p.status AS payment_status, o.status AS order_status, o.order_code
                           FROM payments p
                           JOIN orders o ON o.id = p.order_id
                          WHERE o.order_code = :code
                          ORDER BY p.id DESC
                          LIMIT 1
                            FOR UPDATE'
                    );
                    $pStmt->execute([':code' => $orderCode]);
                }

                $row = $pStmt->fetch();
                if (!$row) {
                    $tx->prepare('UPDATE webhook_events SET status = "IGNORED", processed_at = NOW(), error_message = "Pedido/pagamento não encontrado" WHERE id = :id')
                       ->execute([':id' => $webhookRowId]);
                    return ['status' => 'ignored', 'reason' => 'payment_not_found'];
                }

                $paymentId = (int) $row['id'];
                $orderId = (int) $row['order_id'];
                $currentOrderStatus = (string) $row['order_status'];

                if (in_array($eventType, ['PAYMENT_CONFIRMED', 'PAYMENT_RECEIVED', 'PAID'], true)) {
                    $tx->prepare('UPDATE payments SET status = "PAID", paid_at = COALESCE(paid_at, NOW()) WHERE id = :id')
                       ->execute([':id' => $paymentId]);

                    if ($currentOrderStatus === 'PENDENTE_PAGAMENTO') {
                        $tx->prepare('UPDATE orders SET status = "PAGO" WHERE id = :oid')
                           ->execute([':oid' => $orderId]);
                        $tx->prepare(
                            'INSERT INTO order_status_history (order_id, from_status, to_status, changed_by_staff_id, note)
                             VALUES (:oid, :from_st, "PAGO", NULL, "Pagamento confirmado via webhook")'
                        )->execute([':oid' => $orderId, ':from_st' => $currentOrderStatus]);
                    }
                    $outcome = 'paid';
                } elseif (in_array($eventType, ['PAYMENT_REFUNDED', 'REFUNDED'], true)) {
                    $tx->prepare('UPDATE payments SET status = "REFUNDED" WHERE id = :id')
                       ->execute([':id' => $paymentId]);
                    if ($currentOrderStatus !== 'ESTORNADO') {
                        $tx->prepare('UPDATE orders SET status = "ESTORNADO" WHERE id = :oid')
                           ->execute([':oid' => $orderId]);
                        $tx->prepare(
                            'INSERT INTO order_status_history (order_id, from_status, to_status, changed_by_staff_id, note)
                             VALUES (:oid, :from_st, "ESTORNADO", NULL, "Pagamento estornado via webhook")'
                        )->execute([':oid' => $orderId, ':from_st' => $currentOrderStatus]);
                    }
                    $outcome = 'refunded';
                } elseif (in_array($eventType, ['PAYMENT_FAILED', 'PAYMENT_OVERDUE', 'FAILED'], true)) {
                    $tx->prepare('UPDATE payments SET status = "FAILED" WHERE id = :id')
                       ->execute([':id' => $paymentId]);
                    $outcome = 'failed';
                } else {
                    $tx->prepare('UPDATE webhook_events SET status = "IGNORED", processed_at = NOW() WHERE id = :id')
                       ->execute([':id' => $webhookRowId]);
                    return ['status' => 'ignored', 'reason' => 'unsupported_event_type'];
                }

                $tx->prepare('UPDATE webhook_events SET status = "PROCESSED", processed_at = NOW() WHERE id = :id')
                   ->execute([':id' => $webhookRowId]);

                return ['status' => 'processed', 'outcome' => $outcome, 'order_code' => $row['order_code']];
            });

            return ['status_code' => 200, 'body' => array_merge(['ok' => true, 'event_id' => $eventId], $result)];
        } catch (Throwable $e) {
            $pdo->prepare('UPDATE webhook_events SET status = "FAILED", processed_at = NOW(), error_message = :msg WHERE id = :id')
                ->execute([':msg' => substr($e->getMessage(), 0, 250), ':id' => $webhookRowId]);
            throw $e;
        }
    }
}
