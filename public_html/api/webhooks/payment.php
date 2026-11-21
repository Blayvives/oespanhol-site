<?php
declare(strict_types=1);

require_once dirname(__DIR__) . '/_init.php';
requireHttpMethod(['POST']);

$rawBody = file_get_contents('php://input');
if ($rawBody === false || trim($rawBody) === '') {
    jsonResponse(['error' => 'Corpo do webhook vazio.'], 400);
}

$headers = function_exists('getallheaders') ? (array) getallheaders() : [];
if ($headers === []) {
    foreach ($_SERVER as $key => $value) {
        if (str_starts_with($key, 'HTTP_')) {
            $name = str_replace('_', '-', strtolower(substr($key, 5)));
            $headers[$name] = (string) $value;
        }
    }
}

$result = PaymentService::handleWebhook($rawBody, $headers);
jsonResponse($result['body'], $result['status_code']);
