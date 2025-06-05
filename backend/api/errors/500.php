<?php
/**
 * 500 Error Handler
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
http_response_code(500);

echo json_encode([
    'success' => false,
    'message' => 'Internal server error',
    'error_code' => 500,
    'timestamp' => date('Y-m-d H:i:s'),
    'support' => [
        'email' => 'support@ikiraha.com',
        'phone' => '+250788123456'
    ]
]);
?>
