<?php
declare(strict_types=1);

/**
 * O ESPANHOL — PricingService
 * Cálculo autoritativo no servidor de preços, desconto de rota do Sommelier e frete refrigerado no DF.
 */

final class PricingService
{
    /**
     * Calcula cotação de frete para uma zona ativa do DF (ou retirada no atelier).
     *
     * @return array<string, mixed>
     */
    public static function quoteShipping(
        PDO $pdo,
        string $zoneSlug,
        int $subtotalCents,
        string $fulfillmentType = 'DELIVERY'
    ): array {
        $stmt = $pdo->prepare(
            'SELECT id, slug, name, eta_label, fee_cents, free_shipping_min_cents, delivery_note
               FROM delivery_zones
              WHERE slug = :slug AND is_active = 1
              LIMIT 1'
        );
        $stmt->execute([':slug' => $zoneSlug]);
        $zone = $stmt->fetch();

        if (!$zone) {
            throw new InvalidArgumentException("Região de entrega inválida ou inativa: {$zoneSlug}");
        }

        $feeCents = (int) $zone['fee_cents'];
        $freeMinCents = (int) $zone['free_shipping_min_cents'];

        if ($fulfillmentType === 'PICKUP_ATELIER' || $subtotalCents <= 0) {
            $shippingCents = 0;
        } elseif ($subtotalCents >= $freeMinCents) {
            $shippingCents = 0;
        } else {
            $shippingCents = $feeCents;
        }

        return [
            'delivery_zone_id'        => (int) $zone['id'],
            'zone_slug'               => (string) $zone['slug'],
            'zone_name'               => (string) $zone['name'],
            'eta_label'               => $fulfillmentType === 'PICKUP_ATELIER'
                ? 'Retirada no Atelier (CLS 405, Asa Sul)'
                : (string) $zone['eta_label'],
            'fulfillment_type'        => $fulfillmentType,
            'base_fee_cents'          => $feeCents,
            'free_shipping_min_cents' => $freeMinCents,
            'shipping_cents'          => $shippingCents,
            'is_free_shipping'        => $shippingCents === 0 && $subtotalCents > 0,
            'remaining_for_free_cents'=> $fulfillmentType === 'PICKUP_ATELIER'
                ? 0
                : max(0, $freeMinCents - $subtotalCents),
            'delivery_note'           => (string) $zone['delivery_note'],
        ];
    }

    /**
     * Valida e calcula desconto de Rota do Sommelier exclusivamente a partir das regras no banco.
     * Só concede desconto se o carrinho contiver todos os SKUs mínimos exigidos pela rota.
     *
     * @param array<string, int> $skuQuantities Mapa [sku => qty]
     * @return array{applied_route: ?string, discount_bps: int, discount_cents: int}
     */
    public static function evaluateSommelierDiscount(
        PDO $pdo,
        ?string $routeSlug,
        array $skuQuantities,
        int $subtotalCents
    ): array {
        if ($routeSlug === null || trim($routeSlug) === '' || $subtotalCents <= 0) {
            return ['applied_route' => null, 'discount_bps' => 0, 'discount_cents' => 0];
        }

        $stmt = $pdo->prepare(
            'SELECT slug, discount_bps, rules_json
               FROM sommelier_routes
              WHERE slug = :slug AND is_active = 1
              LIMIT 1'
        );
        $stmt->execute([':slug' => trim($routeSlug)]);
        $route = $stmt->fetch();

        if (!$route) {
            return ['applied_route' => null, 'discount_bps' => 0, 'discount_cents' => 0];
        }

        $rules = json_decode((string) $route['rules_json'], true);
        if (!is_array($rules) || $rules === []) {
            return ['applied_route' => null, 'discount_bps' => 0, 'discount_cents' => 0];
        }

        foreach ($rules as $rule) {
            $sku = (string) ($rule['sku'] ?? '');
            $minQty = isset($rule['fixed_qty'])
                ? (int) $rule['fixed_qty']
                : max(1, (int) ($rule['min_qty'] ?? 1));

            if ($sku === '' || ($skuQuantities[$sku] ?? 0) < $minQty) {
                return ['applied_route' => null, 'discount_bps' => 0, 'discount_cents' => 0];
            }
        }

        $discountBps = (int) $route['discount_bps'];
        $discountCents = (int) round(($subtotalCents * $discountBps) / 10000);

        return [
            'applied_route'  => (string) $route['slug'],
            'discount_bps'   => $discountBps,
            'discount_cents' => min($discountCents, $subtotalCents),
        ];
    }

    /**
     * Simula cotação completa (sem bloquear estoque) para exibição em tempo real no checkout/sacola.
     *
     * @param list<array{sku?: string, product_id?: int, qty: int}> $items
     * @return array<string, mixed>
     */
    public static function quoteCart(
        PDO $pdo,
        array $items,
        string $zoneSlug,
        string $fulfillmentType = 'DELIVERY',
        ?string $sommelierRouteSlug = null
    ): array {
        $subtotalCents = 0;
        $skuQuantities = [];
        $resolvedItems = [];

        $bySkuStmt = $pdo->prepare(
            'SELECT p.id, p.sku, p.name, p.price_cents, p.stock_qty, p.is_active,
                    p.is_made_to_order, p.availability_note, p.weight_label,
                    COALESCE(r.name, "Curadoria Nacional") AS region_name
               FROM products p
               LEFT JOIN regions r ON r.id = p.region_id
              WHERE p.sku = :sku
              LIMIT 1'
        );

        foreach ($items as $entry) {
            $sku = trim((string) ($entry['sku'] ?? ''));
            $qty = (int) ($entry['qty'] ?? 0);
            if ($sku === '' || $qty < 1 || $qty > 99) {
                throw new InvalidArgumentException('Item ou quantidade inválida na cotação.');
            }

            $bySkuStmt->execute([':sku' => $sku]);
            $prod = $bySkuStmt->fetch();
            if (!$prod || (int) $prod['is_active'] !== 1) {
                throw new InvalidArgumentException("Produto indisponível: {$sku}");
            }

            $unitPrice = (int) $prod['price_cents'];
            $lineTotal = $unitPrice * $qty;
            $subtotalCents += $lineTotal;
            $skuQuantities[$sku] = ($skuQuantities[$sku] ?? 0) + $qty;

            $resolvedItems[] = [
                'product_id'        => (int) $prod['id'],
                'sku'               => (string) $prod['sku'],
                'name'              => (string) $prod['name'],
                'region_name'       => (string) $prod['region_name'],
                'weight_label'      => (string) $prod['weight_label'],
                'unit_price_cents'  => $unitPrice,
                'quantity'          => $qty,
                'line_total_cents'  => $lineTotal,
                'stock_qty'         => (int) $prod['stock_qty'],
                'in_stock'          => (int) $prod['stock_qty'] >= $qty,
                'is_made_to_order'  => (int) $prod['is_made_to_order'] === 1,
                'availability_note' => $prod['availability_note'],
            ];
        }

        $discount = self::evaluateSommelierDiscount($pdo, $sommelierRouteSlug, $skuQuantities, $subtotalCents);
        $afterDiscountCents = $subtotalCents - $discount['discount_cents'];
        $shipping = self::quoteShipping($pdo, $zoneSlug, $afterDiscountCents, $fulfillmentType);
        $totalCents = $afterDiscountCents + $shipping['shipping_cents'];

        return [
            'items'           => $resolvedItems,
            'subtotal_cents'  => $subtotalCents,
            'discount_cents'  => $discount['discount_cents'],
            'applied_route'   => $discount['applied_route'],
            'shipping'        => $shipping,
            'shipping_cents'  => $shipping['shipping_cents'],
            'total_cents'     => $totalCents,
        ];
    }
}
