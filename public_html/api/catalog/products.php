<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/_init.php';
$method = requireHttpMethod(['GET', 'POST', 'PUT', 'PATCH']);
$pdo = Database::connection();

// -----------------------------------------------------------------------------
// GET — Listagem pública (com filtro opcional por macro, região, tipo e busca)
//       Se ?include_inactive=1, exige sessão autenticada com catalog.read.
// -----------------------------------------------------------------------------
if ($method === 'GET') {
    $includeInactive = ($_GET['include_inactive'] ?? '0') === '1';
    if ($includeInactive) {
        Rbac::requireAuth('catalog.read', false);
    }

    $where = $includeInactive ? ['1 = 1'] : ['p.is_active = 1'];
    $params = [];

    if (!empty($_GET['region'])) {
        $where[] = 'r.slug = :region';
        $params[':region'] = trim((string) $_GET['region']);
    }
    if (!empty($_GET['macro']) && $_GET['macro'] !== 'todas') {
        $where[] = 'r.macro_region = :macro';
        $params[':macro'] = trim((string) $_GET['macro']);
    }
    if (!empty($_GET['item_type'])) {
        $where[] = 'p.item_type = :itype';
        $params[':itype'] = strtoupper(trim((string) $_GET['item_type']));
    }
    if (!empty($_GET['q'])) {
        $like = '%' . trim((string) $_GET['q']) . '%';
        $where[] = '(p.name LIKE :q1 OR p.short_desc LIKE :q2 OR p.dop_label LIKE :q3 OR COALESCE(r.name, "") LIKE :q4)';
        $params[':q1'] = $like;
        $params[':q2'] = $like;
        $params[':q3'] = $like;
        $params[':q4'] = $like;
    }

    $sql = 'SELECT p.id, p.sku, p.region_id, p.item_type, p.name, p.category, p.dop_label,
                   p.weight_label, p.price_cents, p.stock_qty, p.is_made_to_order,
                   p.availability_note, p.short_desc, p.origin_detail, p.aging_detail,
                   p.serving_detail, p.pairing_detail, p.image_url, p.is_active,
                   r.slug AS region_slug, COALESCE(r.name, "Curadoria Nacional") AS region_name
              FROM products p
              LEFT JOIN regions r ON r.id = p.region_id
             WHERE ' . implode(' AND ', $where) . '
             ORDER BY COALESCE(r.sort_order, 99) ASC, p.id ASC';

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $rows = $stmt->fetchAll();

    jsonResponse([
        'ok'       => true,
        'count'    => count($rows),
        'products' => array_map(static function (array $p): array {
            $p['id'] = (int) $p['id'];
            $p['region_id'] = $p['region_id'] !== null ? (int) $p['region_id'] : null;
            $p['price_cents'] = (int) $p['price_cents'];
            $p['stock_qty'] = (int) $p['stock_qty'];
            $p['is_made_to_order'] = (int) $p['is_made_to_order'] === 1;
            $p['is_active'] = (int) $p['is_active'] === 1;
            return $p;
        }, $rows),
    ]);
}

// -----------------------------------------------------------------------------
// POST / PUT / PATCH — Gestão de catálogo/preço/estoque (ADMIN e GERENTE_OP)
// -----------------------------------------------------------------------------
$staff = Rbac::requireAuth('catalog.write', true);
$body = readJsonBody();

if ($method === 'POST') {
    $sku = trim((string) ($body['sku'] ?? ''));
    $name = trim((string) ($body['name'] ?? ''));
    $category = trim((string) ($body['category'] ?? 'Prato Típico'));
    $dop = trim((string) ($body['dop_label'] ?? 'Origem Espanhola'));
    $weight = trim((string) ($body['weight_label'] ?? 'Unidade'));
    $priceCents = (int) ($body['price_cents'] ?? 0);
    $stockQty = max(0, (int) ($body['stock_qty'] ?? 0));
    $itemType = strtoupper(trim((string) ($body['item_type'] ?? 'DISH')));
    $shortDesc = trim((string) ($body['short_desc'] ?? ''));
    $imageUrl = trim((string) ($body['image_url'] ?? 'assets/hero.jpg'));

    if ($sku === '' || $name === '' || $priceCents <= 0 || !in_array($itemType, ['DISH', 'BOX', 'CLUB_PLAN'], true)) {
        jsonResponse(['error' => 'Informe sku, name, item_type válido e price_cents > 0.'], 400);
    }

    $regionId = null;
    if (!empty($body['region_slug'])) {
        $rStmt = $pdo->prepare('SELECT id FROM regions WHERE slug = :slug LIMIT 1');
        $rStmt->execute([':slug' => trim((string) $body['region_slug'])]);
        $rRow = $rStmt->fetch();
        if (!$rRow) {
            jsonResponse(['error' => 'Comunidade autônoma (region_slug) não encontrada.'], 404);
        }
        $regionId = (int) $rRow['id'];
    }

    $stmt = $pdo->prepare(
        'INSERT INTO products
            (sku, region_id, item_type, name, category, dop_label, weight_label, price_cents, stock_qty,
             is_made_to_order, availability_note, short_desc, origin_detail, aging_detail, serving_detail, pairing_detail, image_url, is_active)
         VALUES
            (:sku, :rid, :itype, :name, :cat, :dop, :weight, :price, :stock,
             :mto, :anote, :sdesc, :origin, :aging, :serving, :pairing, :img, 1)'
    );
    try {
        $stmt->execute([
            ':sku'     => $sku,
            ':rid'     => $regionId,
            ':itype'   => $itemType,
            ':name'    => $name,
            ':cat'     => $category,
            ':dop'     => $dop,
            ':weight'  => $weight,
            ':price'   => $priceCents,
            ':stock'   => $stockQty,
            ':mto'     => !empty($body['is_made_to_order']) ? 1 : 0,
            ':anote'   => trim((string) ($body['availability_note'] ?? '')) ?: null,
            ':sdesc'   => $shortDesc,
            ':origin'  => trim((string) ($body['origin_detail'] ?? '')) ?: null,
            ':aging'   => trim((string) ($body['aging_detail'] ?? '')) ?: null,
            ':serving' => trim((string) ($body['serving_detail'] ?? '')) ?: null,
            ':pairing' => trim((string) ($body['pairing_detail'] ?? '')) ?: null,
            ':img'     => $imageUrl,
        ]);
    } catch (PDOException $e) {
        if ((string) $e->getCode() === '23000') {
            jsonResponse(['error' => "SKU já cadastrado: {$sku}"], 409);
        }
        throw $e;
    }

    $newId = (int) $pdo->lastInsertId();
    Rbac::auditLog((int) $staff['id'], 'PRODUCT_CREATED', 'product', (string) $newId, null, [
        'sku' => $sku, 'name' => $name, 'price_cents' => $priceCents, 'stock_qty' => $stockQty,
    ]);

    jsonResponse(['ok' => true, 'id' => $newId, 'sku' => $sku], 201);
}

// PUT / PATCH — Atualização parcial (preço, estoque, disponibilidade, status ativo)
$productId = (int) ($body['id'] ?? 0);
if ($productId <= 0) {
    jsonResponse(['error' => 'Informe o id do produto a atualizar.'], 400);
}

$curStmt = $pdo->prepare('SELECT id, sku, name, price_cents, stock_qty, is_made_to_order, availability_note, is_active FROM products WHERE id = :id LIMIT 1');
$curStmt->execute([':id' => $productId]);
$current = $curStmt->fetch();
if (!$current) {
    jsonResponse(['error' => 'Produto não encontrado.'], 404);
}

$allowedFields = [
    'name'              => 'string',
    'category'          => 'string',
    'dop_label'         => 'string',
    'weight_label'      => 'string',
    'price_cents'       => 'int_pos',
    'stock_qty'         => 'int_nonneg',
    'is_made_to_order'  => 'bool',
    'availability_note' => 'nullable_string',
    'short_desc'        => 'string',
    'is_active'         => 'bool',
];

$sets = [];
$params = [':id' => $productId];
$newValues = [];

foreach ($allowedFields as $field => $kind) {
    if (!array_key_exists($field, $body)) {
        continue;
    }
    $val = $body[$field];
    if ($kind === 'int_pos') {
        $val = (int) $val;
        if ($val <= 0) {
            jsonResponse(['error' => "Campo {$field} deve ser maior que zero."], 400);
        }
    } elseif ($kind === 'int_nonneg') {
        $val = (int) $val;
        if ($val < 0) {
            jsonResponse(['error' => "Campo {$field} não pode ser negativo."], 400);
        }
    } elseif ($kind === 'bool') {
        $val = $val ? 1 : 0;
    } elseif ($kind === 'nullable_string') {
        $val = trim((string) $val);
        $val = $val === '' ? null : $val;
    } else {
        $val = trim((string) $val);
    }

    $sets[] = "{$field} = :{$field}";
    $params[":{$field}"] = $val;
    $newValues[$field] = $val;
}

if ($sets === []) {
    jsonResponse(['error' => 'Nenhum campo válido informado para atualização.'], 400);
}

$pdo->prepare('UPDATE products SET ' . implode(', ', $sets) . ' WHERE id = :id')->execute($params);

Rbac::auditLog((int) $staff['id'], 'PRODUCT_UPDATED', 'product', (string) $productId, $current, $newValues);

jsonResponse(['ok' => true, 'id' => $productId, 'updated' => $newValues]);
