<?php
// Simple PHP test file to check if PHP is working
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

echo json_encode([
    'status' => 'success',
    'message' => 'PHP is working correctly',
    'php_version' => phpversion(),
    'server_time' => date('Y-m-d H:i:s'),
    'test' => 'This is a simple test file'
]);
?>
