<?php
/**
 * 404 Error Handler
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
http_response_code(404);

echo json_encode([
    'success' => false,
    'message' => 'API endpoint not found',
    'error_code' => 404,
    'timestamp' => date('Y-m-d H:i:s'),
    'available_endpoints' => [
        'auth' => [
            'POST /api/auth/register' => 'User registration',
            'POST /api/auth/login' => 'User login',
            'POST /api/auth/validate' => 'Token validation',
            'POST /api/auth/refresh' => 'Token refresh',
            'GET /api/auth/profile' => 'Get user profile',
            'PUT /api/auth/profile' => 'Update user profile',
            'POST /api/auth/change-password' => 'Change password'
        ],
        'test' => [
            'GET /api/test/database' => 'Database connection test'
        ]
    ]
]);
?>
