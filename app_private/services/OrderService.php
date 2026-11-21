<?php
declare(strict_types=1);

/**
 * O ESPANHOL — OrderService
 * Criação transacional de pedidos com bloqueio de estoque (FOR UPDATE),
 * transições auditadas por papel RBAC e consultas com princípio do menor privilégio.
 */

final class OrderService
{
    /**
     * Cria pedido completo em transação SQL (BEGIN ... COMMIT), bloqueando estoque e recalculando tudo no servidor.
     *
     * @param array<string, mixed> $payload
     * @return array<string, mixed>
     */
    public static function createOrder(array $payload, ?int $assistedByStaffId = null): array
    {
        $itemsInput = $payload['items'] ?? null;
        if (!is_array($itemsInput) || count($itemsInput) === 0) {
            jsonResponse(['error' => 'Adicione ao menos um item ao pedido.'], 400);
        }

        $customerIn = is_array($payload['customer'] ?? null) ? $payload['customer'] : [];
        $fullName = trim((string) ($customerIn['full_name'] ?? ''));
        $email = mb_strtolower(trim((string) ($customerIn['email'] ?? '')), 'UTF-8');
        $phone = trim((string) ($customerIn['phone'] ?? ''));
        $cpf = preg_replace('/\D+/', '', (string) ($customerIn['cpf'] ?? ''));

        if ($fullName === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen(preg_replace('/\D+/', '', $phone)) < 10) {
            jsonResponse(['error' => 'Informe nome completo, e-mail válido e telefone/WhatsApp com DDD.'], 400);
        }

        $fulfillmentType = strtoupper(trim((string) ($payload['fulfillment_type'] ?? 'DELIVERY')));
        if (!in_array($fulfillmentType, ['DELIVERY', 'PICKUP_ATELIER'], true)) {
            $fulfillmentType = 'DELIVERY';
        }

        $zoneSlug = trim((string) ($payload['delivery_zone_slug'] ?? 'asa-sul'));
        $deliveryWindow = trim((string) ($payload['delivery_window'] ?? 'Hoje · Próxima janela refrigerada'));
        $sommelierRouteSlug = isset($payload['sommelier_route_slug']) && $payload['sommelier_route_slug'] !== ''
            ? trim((string) $payload['sommelier_route_slug'])
            : null;
        $customerNotes = trim((string) ($payload['customer_notes'] ?? '')) ?: null;
        $paymentMethod = strtoupper(trim((string) ($payload['payment_method'] ?? 'PIX')));

        $addrIn = is_array($payload['address'] ?? null) ? $payload['address'] : [];
        if ($fulfillmentType === 'DELIVERY') {
            $zip = trim((string) ($addrIn['zip_code'] ?? ''));
            $street = trim((string) ($addrIn['street'] ?? ''));
            $number = trim((string) ($addrIn['number_text'] ?? ''));
            $district = trim((string) ($addrIn['district'] ?? ''));
            if ($zip === '' || $street === '' || $number === '' || $district === '') {
                jsonResponse(['error' => 'Para entrega no DF, informe CEP, quadra/logradouro, número/bloco e bairro/RA.'], 400);
            }
        }

        // Consolida quantidades por SKU e ordena para evitar deadlocks em FOR UPDATE
        $qtyBySku = [];
        foreach ($itemsInput as $entry) {
            $sku = trim((string) ($entry['sku'] ?? ''));
            $qty = (int) ($entry['qty'] ?? 0);
            if ($sku === '' || $qty < 1 || $qty > 99) {
                jsonResponse(['error' => 'SKU ou quantidade inválida no carrinho.'], 400);
            }
            $qtyBySku[$sku] = ($qtyBySku[$sku] ?? 0) + $qty;
        }
        ksort($qtyBySku);

        try {
            return Database::transaction(static function (PDO $pdo) use (
                $qtyBySku,
                $fullName,
                $email,
                $phone,
                $cpf,
                $fulfillmentType,
                $zoneSlug,
                $deliveryWindow,
                $sommelierRouteSlug,
                $customerNotes,
                $paymentMethod,
                $addrIn,
                $assistedByStaffId
            ): array {
                // 1. Bloqueia e valida estoque de cada item (FOR UPDATE)
                $lockStmt = $pdo->prepare(
                    'SELECT p.id, p.sku, p.item_type, p.name, p.price_cents, p.stock_qty, p.is_active,
                            p.is_made_to_order, p.availability_note,
                            COALESCE(r.name, "Curadoria Nacional") AS region_name
                       FROM products p
                       LEFT JOIN regions r ON r.id = p.region_id
                      WHERE p.sku = :sku
                      LIMIT 1
                        FOR UPDATE'
                );

                $lockedProducts = [];
                $subtotalCents = 0;

                foreach ($qtyBySku as $sku => $qty) {
                    $lockStmt->execute([':sku' => $sku]);
                    $prod = $lockStmt->fetch();

                    if (!$prod || (int) $prod['is_active'] !== 1) {
                        throw new DomainException("UNAVAILABLE::{$sku}::Produto indisponível no catálogo.");
                    }
                    if ((int) $prod['stock_qty'] < $qty) {
                        $avail = (int) $prod['stock_qty'];
                        throw new DomainException("CONFLICT::{$sku}::Estoque insuficiente para {$prod['name']} (disponível: {$avail}).");
                    }

                    $unitCents = (int) $prod['price_cents'];
                    $lineCents = $unitCents * $qty;
                    $subtotalCents += $lineCents;

                    $lockedProducts[] = [
                        'product'          => $prod,
                        'qty'              => $qty,
                        'unit_price_cents' => $unitCents,
                        'line_total_cents' => $lineCents,
                    ];
                }

                // 2. Recalcula desconto de rota e frete exclusivamente no servidor
                $discount = PricingService::evaluateSommelierDiscount($pdo, $sommelierRouteSlug, $qtyBySku, $subtotalCents);
                $afterDiscount = $subtotalCents - $discount['discount_cents'];
                $shipping = PricingService::quoteShipping($pdo, $zoneSlug, $afterDiscount, $fulfillmentType);
                $totalCents = $afterDiscount + $shipping['shipping_cents'];

                // 3. Cria/atualiza cliente
                $cStmt = $pdo->prepare('SELECT id FROM customers WHERE email = :email LIMIT 1');
                $cStmt->execute([':email' => $email]);
                $existingCustomer = $cStmt->fetch();

                if ($existingCustomer) {
                    $customerId = (int) $existingCustomer['id'];
                    $pdo->prepare('UPDATE customers SET full_name = :name, phone = :phone, cpf = COALESCE(:cpf, cpf) WHERE id = :id')
                        ->execute([
                            ':name'  => $fullName,
                            ':phone' => $phone,
                            ':cpf'   => $cpf !== '' ? $cpf : null,
                            ':id'    => $customerId,
                        ]);
                } else {
                    $pdo->prepare('INSERT INTO customers (full_name, email, phone, cpf) VALUES (:name, :email, :phone, :cpf)')
                        ->execute([
                            ':name'  => $fullName,
                            ':email' => $email,
                            ':phone' => $phone,
                            ':cpf'   => $cpf !== '' ? $cpf : null,
                        ]);
                    $customerId = (int) $pdo->lastInsertId();
                }

                // 4. Grava endereço de entrega (quando DELIVERY)
                $addressId = null;
                if ($fulfillmentType === 'DELIVERY') {
                    $aStmt = $pdo->prepare(
                        'INSERT INTO customer_addresses
                            (customer_id, delivery_zone_id, zip_code, street, number_text, complement, district, city, state_uf, reference_note)
                         VALUES
                            (:customer_id, :zone_id, :zip, :street, :num, :comp, :district, :city, :uf, :ref)'
                    );
                    $aStmt->execute([
                        ':customer_id' => $customerId,
                        ':zone_id'     => $shipping['delivery_zone_id'],
                        ':zip'         => substr(trim((string) $addrIn['zip_code']), 0, 10),
                        ':street'      => substr(trim((string) $addrIn['street']), 0, 180),
                        ':num'         => substr(trim((string) $addrIn['number_text']), 0, 40),
                        ':comp'        => trim((string) ($addrIn['complement'] ?? '')) ?: null,
                        ':district'    => substr(trim((string) $addrIn['district']), 0, 100),
                        ':city'        => substr(trim((string) ($addrIn['city'] ?? 'Brasília')), 0, 80),
                        ':uf'          => strtoupper(substr(trim((string) ($addrIn['state_uf'] ?? 'DF')), 0, 2)),
                        ':ref'         => trim((string) ($addrIn['reference_note'] ?? '')) ?: null,
                    ]);
                    $addressId = (int) $pdo->lastInsertId();
                }

                // 5. Cria pedido com código único
                $orderCode = sprintf('ESP-%s-%s', date('Ymd'), strtoupper(bin2hex(random_bytes(3))));
                $oStmt = $pdo->prepare(
                    'INSERT INTO orders
                        (order_code, customer_id, address_id, delivery_zone_id, fulfillment_type, delivery_window,
                         sommelier_route_slug, status, subtotal_cents, discount_cents, shipping_cents, total_cents, customer_notes)
                     VALUES
                        (:code, :cid, :aid, :zid, :ftype, :dwin, :route, "PENDENTE_PAGAMENTO",
                         :sub, :disc, :ship, :tot, :notes)'
                );
                $oStmt->execute([
                    ':code'  => $orderCode,
                    ':cid'   => $customerId,
                    ':aid'   => $addressId,
                    ':zid'   => $shipping['delivery_zone_id'],
                    ':ftype' => $fulfillmentType,
                    ':dwin'  => substr($deliveryWindow, 0, 80),
                    ':route' => $discount['applied_route'],
                    ':sub'   => $subtotalCents,
                    ':disc'  => $discount['discount_cents'],
                    ':ship'  => $shipping['shipping_cents'],
                    ':tot'   => $totalCents,
                    ':notes' => $customerNotes,
                ]);
                $orderId = (int) $pdo->lastInsertId();

                // 6. Insere order_items, abate estoque e registra assinatura se houver CLUB_PLAN
                $itemStmt = $pdo->prepare(
                    'INSERT INTO order_items
                        (order_id, product_id, product_name_snapshot, region_name_snapshot, unit_price_cents, quantity, line_total_cents)
                     VALUES
                        (:oid, :pid, :pname, :rname, :uprice, :qty, :ltotal)'
                );
                $stockStmt = $pdo->prepare('UPDATE products SET stock_qty = stock_qty - :qty WHERE id = :pid');

                $responseItems = [];
                foreach ($lockedProducts as $row) {
                    $p = $row['product'];
                    $itemStmt->execute([
                        ':oid'    => $orderId,
                        ':pid'    => (int) $p['id'],
                        ':pname'  => (string) $p['name'],
                        ':rname'  => (string) $p['region_name'],
                        ':uprice' => $row['unit_price_cents'],
                        ':qty'    => $row['qty'],
                        ':ltotal' => $row['line_total_cents'],
                    ]);
                    $stockStmt->execute([':qty' => $row['qty'], ':pid' => (int) $p['id']]);

                    if ((string) $p['item_type'] === 'CLUB_PLAN' && $addressId !== null) {
                        $pdo->prepare(
                            'INSERT INTO club_subscriptions
                                (customer_id, address_id, product_id, plan_name_snapshot, monthly_price_cents, status, started_at, next_billing_date)
                             VALUES
                                (:cid, :aid, :pid, :pname, :mprice, "ATIVA", CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 MONTH))'
                        )->execute([
                            ':cid'    => $customerId,
                            ':aid'    => $addressId,
                            ':pid'    => (int) $p['id'],
                            ':pname'  => (string) $p['name'],
                            ':mprice' => $row['unit_price_cents'],
                        ]);
                    }

                    $responseItems[] = [
                        'sku'              => (string) $p['sku'],
                        'name'             => (string) $p['name'],
                        'region_name'      => (string) $p['region_name'],
                        'unit_price_cents' => $row['unit_price_cents'],
                        'quantity'         => $row['qty'],
                        'line_total_cents' => $row['line_total_cents'],
                    ];
                }

                // 7. Histórico inicial de status
                $pdo->prepare(
                    'INSERT INTO order_status_history (order_id, from_status, to_status, changed_by_staff_id, note)
                     VALUES (:oid, NULL, "PENDENTE_PAGAMENTO", :staff_id, :note)'
                )->execute([
                    ':oid'      => $orderId,
                    ':staff_id' => $assistedByStaffId,
                    ':note'     => $assistedByStaffId !== null ? 'Pedido registrado via atendimento assistido' : 'Pedido criado pela vitrine',
                ]);

                // 8. Intenção de pagamento
                $payment = PaymentService::createPendingPayment($pdo, $orderId, $orderCode, $totalCents, $paymentMethod);

                if ($assistedByStaffId !== null) {
                    Rbac::auditLog($assistedByStaffId, 'ORDER_CREATED_ASSISTED', 'order', $orderCode, null, [
                        'order_id'    => $orderId,
                        'total_cents' => $totalCents,
                    ]);
                }

                return [
                    'order_id'         => $orderId,
                    'order_code'       => $orderCode,
                    'status'           => 'PENDENTE_PAGAMENTO',
                    'fulfillment_type' => $fulfillmentType,
                    'delivery_window'  => $deliveryWindow,
                    'zone_name'        => $shipping['zone_name'],
                    'eta_label'        => $shipping['eta_label'],
                    'subtotal_cents'   => $subtotalCents,
                    'discount_cents'   => $discount['discount_cents'],
                    'applied_route'    => $discount['applied_route'],
                    'shipping_cents'   => $shipping['shipping_cents'],
                    'total_cents'      => $totalCents,
                    'items'            => $responseItems,
                    'payment'          => $payment,
                ];
            });
        } catch (DomainException $e) {
            $parts = explode('::', $e->getMessage(), 3);
            $code = $parts[0] ?? 'CONFLICT';
            $sku = $parts[1] ?? null;
            $msg = $parts[2] ?? $e->getMessage();
            jsonResponse(['error' => $msg, 'sku' => $sku, 'code' => $code], 409);
        } catch (InvalidArgumentException $e) {
            jsonResponse(['error' => $e->getMessage()], 400);
        }
    }

    /**
     * Transiciona status de pedido respeitando estritamente a máquina de estados RBAC.
     *
     * @param array<string, mixed> $staffUser
     * @return array<string, mixed>
     */
    public static function transitionStatus(
        int $orderId,
        string $toStatus,
        array $staffUser,
        ?string $note = null
    ): array {
        $toStatus = strtoupper(trim($toStatus));
        $role = (string) $staffUser['role'];
        $staffId = (int) $staffUser['id'];

        return Database::transaction(static function (PDO $pdo) use ($orderId, $toStatus, $role, $staffId, $note): array {
            $stmt = $pdo->prepare('SELECT id, order_code, status FROM orders WHERE id = :id LIMIT 1 FOR UPDATE');
            $stmt->execute([':id' => $orderId]);
            $order = $stmt->fetch();

            if (!$order) {
                jsonResponse(['error' => 'Pedido não encontrado.'], 404);
            }

            $fromStatus = (string) $order['status'];
            if (!Rbac::canTransitionOrderStatus($role, $fromStatus, $toStatus)) {
                Rbac::auditLog($staffId, 'ORDER_STATUS_DENIED', 'order', (string) $order['order_code'], ['status' => $fromStatus], ['attempted' => $toStatus, 'role' => $role]);
                jsonResponse([
                    'error' => "Transição não permitida para {$role}: {$fromStatus} → {$toStatus}.",
                ], 403);
            }

            $setAssigned = '';
            $params = [':to_status' => $toStatus, ':id' => $orderId];
            if ($role === 'COZINHA_CORTE' && $toStatus === 'EM_PREPARO') {
                $setAssigned = ', assigned_kitchen_staff_id = :sid';
                $params[':sid'] = $staffId;
            } elseif ($role === 'LOGISTICA_ENTREGA' && $toStatus === 'SAIU_PARA_ENTREGA') {
                $setAssigned = ', assigned_courier_staff_id = :sid';
                $params[':sid'] = $staffId;
            }

            $pdo->prepare("UPDATE orders SET status = :to_status{$setAssigned} WHERE id = :id")->execute($params);

            // Estorna estoque automaticamente se cancelado antes da saída para entrega
            if (
                $toStatus === 'CANCELADO' &&
                in_array($fromStatus, ['PENDENTE_PAGAMENTO', 'PAGO', 'EM_PREPARO', 'PRONTO_EXPEDICAO'], true)
            ) {
                $itemsStmt = $pdo->prepare('SELECT product_id, quantity FROM order_items WHERE order_id = :oid');
                $itemsStmt->execute([':oid' => $orderId]);
                $restoreStmt = $pdo->prepare('UPDATE products SET stock_qty = stock_qty + :qty WHERE id = :pid');
                foreach ($itemsStmt->fetchAll() as $it) {
                    $restoreStmt->execute([':qty' => (int) $it['quantity'], ':pid' => (int) $it['product_id']]);
                }
            }

            $pdo->prepare(
                'INSERT INTO order_status_history (order_id, from_status, to_status, changed_by_staff_id, note)
                 VALUES (:oid, :from_st, :to_st, :sid, :note)'
            )->execute([
                ':oid'     => $orderId,
                ':from_st' => $fromStatus,
                ':to_st'   => $toStatus,
                ':sid'     => $staffId,
                ':note'    => $note !== null && trim($note) !== '' ? substr(trim($note), 0, 255) : null,
            ]);

            Rbac::auditLog(
                $staffId,
                'ORDER_STATUS_UPDATED',
                'order',
                (string) $order['order_code'],
                ['status' => $fromStatus],
                ['status' => $toStatus, 'note' => $note]
            );

            return [
                'order_id'    => $orderId,
                'order_code'  => (string) $order['order_code'],
                'from_status' => $fromStatus,
                'to_status'   => $toStatus,
            ];
        });
    }

    /**
     * Lista pedidos aplicando projeção de dados conforme o papel do empregado (Menor Privilégio).
     *
     * @param array<string, mixed> $staffUser
     * @param array<string, mixed> $filters
     * @return list<array<string, mixed>>
     */
    public static function listOrdersForStaff(array $staffUser, array $filters = []): array
    {
        $pdo = Database::connection();
        $role = (string) $staffUser['role'];

        $where = ['1 = 1'];
        $params = [];

        // Restrição de fila operacional por papel
        if ($role === 'COZINHA_CORTE') {
            $where[] = "o.status IN ('PAGO', 'EM_PREPARO', 'PRONTO_EXPEDICAO')";
        } elseif ($role === 'LOGISTICA_ENTREGA') {
            $where[] = "o.status IN ('PRONTO_EXPEDICAO', 'SAIU_PARA_ENTREGA', 'ENTREGUE')";
        }

        if (!empty($filters['status'])) {
            $where[] = 'o.status = :status';
            $params[':status'] = strtoupper(trim((string) $filters['status']));
        }
        if (!empty($filters['zone'])) {
            $where[] = 'dz.slug = :zone';
            $params[':zone'] = trim((string) $filters['zone']);
        }
        if (!empty($filters['q'])) {
            $where[] = '(o.order_code LIKE :q OR c.full_name LIKE :q2)';
            $like = '%' . trim((string) $filters['q']) . '%';
            $params[':q'] = $like;
            $params[':q2'] = $like;
        }

        $limit = max(1, min(100, (int) ($filters['limit'] ?? 50)));

        $sql = 'SELECT o.id, o.order_code, o.status, o.fulfillment_type, o.delivery_window,
                       o.sommelier_route_slug, o.subtotal_cents, o.discount_cents, o.shipping_cents, o.total_cents,
                       o.customer_notes, o.created_at, o.updated_at,
                       dz.slug AS zone_slug, dz.name AS zone_name, dz.eta_label,
                       c.full_name AS customer_name, c.email AS customer_email, c.phone AS customer_phone,
                       ca.zip_code, ca.street, ca.number_text, ca.complement, ca.district, ca.reference_note
                  FROM orders o
                  JOIN delivery_zones dz ON dz.id = o.delivery_zone_id
                  JOIN customers c ON c.id = o.customer_id
                  LEFT JOIN customer_addresses ca ON ca.id = o.address_id
                 WHERE ' . implode(' AND ', $where) . '
                 ORDER BY o.created_at DESC
                 LIMIT ' . $limit;

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $orders = $stmt->fetchAll();

        if ($orders === []) {
            return [];
        }

        $orderIds = array_map(static fn(array $o): int => (int) $o['id'], $orders);
        $placeholders = implode(',', array_fill(0, count($orderIds), '?'));

        $itemsStmt = $pdo->prepare(
            "SELECT oi.order_id, oi.product_name_snapshot, oi.region_name_snapshot,
                    oi.unit_price_cents, oi.quantity, oi.line_total_cents,
                    p.weight_label, p.is_made_to_order, p.availability_note, p.serving_detail
               FROM order_items oi
               JOIN products p ON p.id = oi.product_id
              WHERE oi.order_id IN ({$placeholders})
              ORDER BY oi.id ASC"
        );
        $itemsStmt->execute($orderIds);
        $itemsByOrder = [];
        foreach ($itemsStmt->fetchAll() as $it) {
            $oid = (int) $it['order_id'];
            if ($role === 'COZINHA_CORTE' || $role === 'LOGISTICA_ENTREGA') {
                unset($it['unit_price_cents'], $it['line_total_cents']);
            }
            $itemsByOrder[$oid][] = $it;
        }

        $histStmt = $pdo->prepare(
            "SELECT h.order_id, h.from_status, h.to_status, h.note, h.created_at,
                    COALESCE(su.full_name, 'Sistema / Webhook') AS changed_by
               FROM order_status_history h
               LEFT JOIN staff_users su ON su.id = h.changed_by_staff_id
              WHERE h.order_id IN ({$placeholders})
              ORDER BY h.created_at ASC"
        );
        $histStmt->execute($orderIds);
        $histByOrder = [];
        foreach ($histStmt->fetchAll() as $h) {
            $histByOrder[(int) $h['order_id']][] = $h;
        }

        // Aplica projeção por papel
        return array_map(static function (array $o) use ($role, $itemsByOrder, $histByOrder): array {
            $oid = (int) $o['id'];
            $base = [
                'id'               => $oid,
                'order_code'       => $o['order_code'],
                'status'           => $o['status'],
                'fulfillment_type' => $o['fulfillment_type'],
                'delivery_window'  => $o['delivery_window'],
                'zone_slug'        => $o['zone_slug'],
                'zone_name'        => $o['zone_name'],
                'customer_notes'   => $o['customer_notes'],
                'created_at'       => $o['created_at'],
                'items'            => $itemsByOrder[$oid] ?? [],
                'history'          => $histByOrder[$oid] ?? [],
            ];

            if ($role === 'COZINHA_CORTE') {
                // Sem dados financeiros nem telefone/endereço completo do cliente
                return $base;
            }

            if ($role === 'LOGISTICA_ENTREGA') {
                $base['customer'] = [
                    'name'  => $o['customer_name'],
                    'phone' => $o['customer_phone'],
                ];
                $base['address'] = [
                    'zip_code'       => $o['zip_code'],
                    'street'         => $o['street'],
                    'number_text'    => $o['number_text'],
                    'complement'     => $o['complement'],
                    'district'       => $o['district'],
                    'reference_note' => $o['reference_note'],
                ];
                return $base;
            }

            // ADMIN, GERENTE_OP, CONCIERGE
            $base['customer'] = [
                'name'  => $o['customer_name'],
                'email' => $o['customer_email'],
                'phone' => $o['customer_phone'],
            ];
            $base['address'] = [
                'zip_code'       => $o['zip_code'],
                'street'         => $o['street'],
                'number_text'    => $o['number_text'],
                'complement'     => $o['complement'],
                'district'       => $o['district'],
                'reference_note' => $o['reference_note'],
            ];
            $base['totals'] = [
                'subtotal_cents' => (int) $o['subtotal_cents'],
                'discount_cents' => (int) $o['discount_cents'],
                'shipping_cents' => (int) $o['shipping_cents'],
                'total_cents'    => (int) $o['total_cents'],
            ];
            return $base;
        }, $orders);
    }
}
