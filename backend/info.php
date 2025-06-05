<?php
// Backend API Information - Simplified Version
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$info = [
    'name' => 'Ikiraha Mobile Backend API',
    'version' => '1.0.0',
    'status' => 'active',
    'timestamp' => date('Y-m-d H:i:s'),
    'php_version' => phpversion(),
    'server_info' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
    'endpoints' => [
        'GET /info.php' => 'API Information',
        'GET /simple_test.php' => 'Simple PHP Test',
        'GET /test_db.php' => 'Database Test',
        'POST /api/auth/register' => 'User Registration',
        'POST /api/auth/login' => 'User Login'
    ],
    'message' => 'Backend API is running successfully'
];

echo json_encode($info, JSON_PRETTY_PRINT);
?>
