<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/_init.php';
requireHttpMethod(['GET']);

$pdo = Database::connection();
$macro = trim((string) ($_GET['macro'] ?? ''));
$includeDishes = ($_GET['include_dishes'] ?? '1') !== '0';

$where = ['is_active = 1'];
$params = [];
if ($macro !== '' && $macro !== 'todas') {
    $where[] = 'macro_region = :macro';
    $params[':macro'] = $macro;
}

$stmt = $pdo->prepare(
    'SELECT id, slug, code, name, spanish_name, capital, macro_region, macro_label,
            accent_hex, accent_soft, motif_key, motif_label, dops_json,
            tagline, story, ritual, map_x, map_y, sort_order
       FROM regions
      WHERE ' . implode(' AND ', $where) . '
      ORDER BY sort_order ASC'
);
$stmt->execute($params);
$regionsRows = $stmt->fetchAll();

$dishesByRegion = [];
$extraItems = [];

if ($includeDishes) {
    $pStmt = $pdo->query(
        'SELECT id, sku, region_id, item_type, name, category, dop_label, weight_label,
                price_cents, stock_qty, is_made_to_order, availability_note,
                short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url
           FROM products
          WHERE is_active = 1
          ORDER BY id ASC'
    );
    foreach ($pStmt->fetchAll() as $p) {
        $item = [
            'id'                => (int) $p['id'],
            'sku'               => $p['sku'],
            'item_type'         => $p['item_type'],
            'name'              => $p['name'],
            'type'              => $p['category'],
            'dop'               => $p['dop_label'],
            'weight'            => $p['weight_label'],
            'price_cents'       => (int) $p['price_cents'],
            'price'             => ((int) $p['price_cents']) / 100,
            'stock_qty'         => (int) $p['stock_qty'],
            'in_stock'          => ((int) $p['stock_qty']) > 0,
            'is_made_to_order'  => ((int) $p['is_made_to_order']) === 1,
            'availability_note' => $p['availability_note'],
            'shortDesc'         => $p['short_desc'],
            'origin'            => $p['origin_detail'],
            'aging'             => $p['aging_detail'],
            'serving'           => $p['serving_detail'],
            'pairing'           => $p['pairing_detail'],
            'img'               => './' . ltrim((string) $p['image_url'], './'),
        ];

        if ($p['region_id'] !== null) {
            $dishesByRegion[(int) $p['region_id']][] = $item;
        } else {
            $extraItems[$p['sku']] = $item;
        }
    }
}

$regions = array_map(static function (array $r) use ($dishesByRegion, $includeDishes): array {
    $rid = (int) $r['id'];
    $out = [
        'region_id'   => $rid,
        'id'          => $r['slug'],
        'code'        => $r['code'],
        'name'        => $r['name'],
        'spanishName' => $r['spanish_name'],
        'capital'     => $r['capital'],
        'macro'       => $r['macro_region'],
        'macroLabel'  => $r['macro_label'],
        'accent'      => $r['accent_hex'],
        'accentSoft'  => $r['accent_soft'],
        'motifKey'    => $r['motif_key'],
        'motifLabel'  => $r['motif_label'],
        'dops'        => json_decode((string) $r['dops_json'], true) ?: [],
        'tagline'     => $r['tagline'],
        'story'       => $r['story'],
        'ritual'      => $r['ritual'],
        'mapPos'      => ['x' => (int) $r['map_x'], 'y' => (int) $r['map_y']],
    ];
    if ($includeDishes) {
        $out['dishes'] = $dishesByRegion[$rid] ?? [];
    }
    return $out;
}, $regionsRows);

$routesRows = $pdo->query(
    'SELECT slug, title, subtitle, curator_note, discount_bps, rules_json
       FROM sommelier_routes
      WHERE is_active = 1
      ORDER BY sort_order ASC'
)->fetchAll();

$routes = array_map(static fn(array $rt): array => [
    'slug'         => $rt['slug'],
    'title'        => $rt['title'],
    'subtitle'     => $rt['subtitle'],
    'note'         => $rt['curator_note'],
    'discount_bps' => (int) $rt['discount_bps'],
    'rules'        => json_decode((string) $rt['rules_json'], true) ?: [],
], $routesRows);

jsonResponse([
    'ok'               => true,
    'regions_count'    => count($regions),
    'regions'          => $regions,
    'extra_items'      => $extraItems,
    'sommelier_routes' => $routes,
]);
