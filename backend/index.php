<?php
/**
 * Ikiraha Mobile Backend API
 * Main entry point and API documentation
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$apiInfo = [
    'name' => 'Ikiraha Mobile Backend API',
    'version' => '1.0.0',
    'description' => 'Comprehensive PHP backend API for the Ikiraha Mobile food ordering system',
    'status' => 'active',
    'timestamp' => date('Y-m-d H:i:s'),
    'endpoints' => [
        'authentication' => [
            'POST /api/auth/register' => 'User registration',
            'POST /api/auth/login' => 'User login',
            'POST /api/auth/validate' => 'Token validation',
            'POST /api/auth/refresh' => 'Token refresh',
            'GET /api/auth/profile' => 'Get user profile',
            'PUT /api/auth/profile' => 'Update user profile',
            'POST /api/auth/change-password' => 'Change password'
        ],
        'testing' => [
            'GET /api/test/database' => 'Database connection test'
        ]
    ],
    'features' => [
        'JWT Authentication',
        'User Registration & Login',
        'Password Security (Bcrypt)',
        'Input Validation',
        'CORS Support',
        'Error Handling',
        'Rate Limiting',
        'Database Integration (MySQL)',
        'Middleware Support'
    ],
    'database' => [
        'type' => 'MySQL',
        'name' => 'ikiraha_ordering_system',
        'tables' => '52 tables',
        'features' => [
            'Multi-user roles',
            'Restaurant management',
            'Product catalog',
            'Order processing',
            'Payment integration',
            'Customer analytics',
            'Recommendation system'
        ]
    ],
    'documentation' => [
        'readme' => '/backend/README.md',
        'postman_collection' => 'Available on request',
        'api_reference' => 'See README.md for detailed documentation'
    ],
    'support' => [
        'email' => 'support@ikiraha.com',
        'phone' => '+250788123456'
    ]
];

echo json_encode($apiInfo, JSON_PRETTY_PRINT);
?>
