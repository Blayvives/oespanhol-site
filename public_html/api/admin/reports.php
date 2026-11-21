<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/_init.php';
requireHttpMethod(['GET']);

// Acessível para ADMIN e GERENTE_OP (reports.read)
Rbac::requireAuth('reports.read', false);
$pdo = Database::connection();

$days = max(1, min(365, (int) ($_GET['days'] ?? 30)));

$summaryStmt = $pdo->prepare(
    "SELECT COUNT(*) AS total_orders,
            SUM(CASE WHEN status NOT IN ('CANCELADO', 'ESTORNADO', 'PENDENTE_PAGAMENTO') THEN total_cents ELSE 0 END) AS paid_revenue_cents,
            AVG(CASE WHEN status NOT IN ('CANCELADO', 'ESTORNADO', 'PENDENTE_PAGAMENTO') THEN total_cents ELSE NULL END) AS avg_ticket_cents
       FROM orders
      WHERE created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)"
);
$summaryStmt->execute([':days' => $days]);
$summary = $summaryStmt->fetch() ?: [];

$byStatusStmt = $pdo->prepare(
    'SELECT status, COUNT(*) AS orders_count, SUM(total_cents) AS total_cents
       FROM orders
      WHERE created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)
      GROUP BY status'
);
$byStatusStmt->execute([':days' => $days]);

$byZoneStmt = $pdo->prepare(
    'SELECT dz.name AS zone_name, COUNT(*) AS orders_count, SUM(o.total_cents) AS revenue_cents
       FROM orders o
       JOIN delivery_zones dz ON dz.id = o.delivery_zone_id
      WHERE o.created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)
      GROUP BY dz.id, dz.name
      ORDER BY orders_count DESC'
);
$byZoneStmt->execute([':days' => $days]);

$byRegionStmt = $pdo->prepare(
    "SELECT oi.region_name_snapshot AS region_name,
            SUM(oi.quantity) AS units_sold,
            SUM(oi.line_total_cents) AS revenue_cents
       FROM order_items oi
       JOIN orders o ON o.id = oi.order_id
      WHERE o.created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)
        AND o.status NOT IN ('CANCELADO', 'ESTORNADO')
      GROUP BY oi.region_name_snapshot
      ORDER BY revenue_cents DESC
      LIMIT 10"
);
$byRegionStmt->execute([':days' => $days]);

$lowStock = $pdo->query(
    'SELECT id, sku, name, stock_qty, is_made_to_order
       FROM products
      WHERE is_active = 1 AND stock_qty <= 5
      ORDER BY stock_qty ASC
      LIMIT 20'
)->fetchAll();

jsonResponse([
    'ok'          => true,
    'window_days' => $days,
    'summary'     => [
        'total_orders'       => (int) ($summary['total_orders'] ?? 0),
        'paid_revenue_cents' => (int) ($summary['paid_revenue_cents'] ?? 0),
        'avg_ticket_cents'   => (int) round((float) ($summary['avg_ticket_cents'] ?? 0)),
    ],
    'by_status'   => $byStatusStmt->fetchAll(),
    'by_df_zone'  => $byZoneStmt->fetchAll(),
    'top_regions' => $byRegionStmt->fetchAll(),
    'low_stock'   => $lowStock,
]);
