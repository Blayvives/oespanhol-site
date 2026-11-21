<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/_init.php';
$method = requireHttpMethod(['GET', 'POST']);
$pdo = Database::connection();

if ($method === 'GET') {
    $zoneSlug = trim((string) ($_GET['zone'] ?? ''));

    // Sem parâmetro zone: lista todas as zonas ativas do DF
    if ($zoneSlug === '') {
        $zones = $pdo->query(
            'SELECT id, slug, name, eta_label, fee_cents, free_shipping_min_cents, delivery_note
               FROM delivery_zones
              WHERE is_active = 1
              ORDER BY sort_order ASC'
        )->fetchAll();

        jsonResponse([
            'ok'    => true,
            'zones' => array_map(static function (array $z): array {
                return [
                    'id'                      => (int) $z['id'],
                    'slug'                    => $z['slug'],
                    'name'                    => $z['name'],
                    'eta_label'               => $z['eta_label'],
                    'fee_cents'               => (int) $z['fee_cents'],
                    'free_shipping_min_cents' => (int) $z['free_shipping_min_cents'],
                    'delivery_note'           => $z['delivery_note'],
                ];
            }, $zones),
        ]);
    }

    $subtotalCents = max(0, (int) ($_GET['subtotal_cents'] ?? 0));
    $fulfillment = strtoupper(trim((string) ($_GET['fulfillment_type'] ?? 'DELIVERY')));
    try {
        $quote = PricingService::quoteShipping($pdo, $zoneSlug, $subtotalCents, $fulfillment);
        jsonResponse(['ok' => true, 'quote' => $quote]);
    } catch (InvalidArgumentException $e) {
        jsonResponse(['error' => $e->getMessage()], 400);
    }
}

// POST — Cotação completa do carrinho + rota do Sommelier + frete DF no servidor
$body = readJsonBody();
$items = is_array($body['items'] ?? null) ? $body['items'] : [];
$zoneSlug = trim((string) ($body['delivery_zone_slug'] ?? 'lago-sul'));
$fulfillment = strtoupper(trim((string) ($body['fulfillment_type'] ?? 'DELIVERY')));
$routeSlug = isset($body['sommelier_route_slug']) ? (string) $body['sommelier_route_slug'] : null;

try {
    $quote = PricingService::quoteCart($pdo, $items, $zoneSlug, $fulfillment, $routeSlug);
    jsonResponse(['ok' => true, 'quote' => $quote]);
} catch (InvalidArgumentException $e) {
    jsonResponse(['error' => $e->getMessage()], 400);
}
