<?php
/**
 * Ikiraha Mobile API - Main Entry Point
 * Handles CORS and routes requests to appropriate endpoints
 */

// Enable CORS for all origins (adjust for production)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Get the request URI and remove the base path
$request_uri = $_SERVER['REQUEST_URI'];
$base_path = '/ikiraha_api';

// Remove base path and query string
$path = parse_url($request_uri, PHP_URL_PATH);
$path = str_replace($base_path, '', $path);

// Route to appropriate endpoint
switch (true) {
    case preg_match('/^\/restaurants/', $path):
        require_once __DIR__ . '/restaurants.php';
        break;
        
    case preg_match('/^\/users/', $path):
        require_once __DIR__ . '/users.php';
        break;
        
    case preg_match('/^\/auth/', $path):
        require_once __DIR__ . '/auth.php';
        break;
        
    case $path === '/' || $path === '':
        // API info endpoint
        echo json_encode([
            'success' => true,
            'message' => 'Ikiraha Mobile API',
            'version' => '1.0.0',
            'timestamp' => date('Y-m-d H:i:s'),
            'endpoints' => [
                '/restaurants' => 'Restaurant management',
                '/users' => 'User management',
                '/auth' => 'Authentication'
            ]
        ]);
        break;
        
    default:
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Endpoint not found: ' . $path,
            'timestamp' => date('Y-m-d H:i:s')
        ]);
        break;
}
?>
