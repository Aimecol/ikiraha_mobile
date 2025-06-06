<?php
// CORS Headers for Ikiraha API
// Add this to your main API entry point or create a middleware

class CorsHandler {
    
    public static function handleCors() {
        // Allow requests from Flutter web app
        $allowedOrigins = [
            'http://localhost:52695',
            'http://localhost:3000',
            'http://127.0.0.1:52695',
            'http://127.0.0.1:3000',
            // Add your production domain here
            'https://yourdomain.com'
        ];
        
        $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
        
        if (in_array($origin, $allowedOrigins)) {
            header("Access-Control-Allow-Origin: $origin");
        }
        
        // Allow specific headers
        header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Accept, Origin");
        
        // Allow specific methods
        header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH");
        
        // Allow credentials (for authentication)
        header("Access-Control-Allow-Credentials: true");
        
        // Cache preflight response for 1 hour
        header("Access-Control-Max-Age: 3600");
        
        // Handle preflight OPTIONS request
        if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
            http_response_code(200);
            exit();
        }
    }
}

// Usage in your API entry point (index.php or api.php)
// Add this at the very beginning of your API files:

// Enable CORS
CorsHandler::handleCors();

// Example API endpoint structure
if ($_SERVER['REQUEST_METHOD'] === 'GET' && $_SERVER['REQUEST_URI'] === '/ikiraha_api/users') {
    // Your users API logic here
    header('Content-Type: application/json');
    
    // Sample response
    $response = [
        'success' => true,
        'data' => [
            [
                'id' => 1,
                'uuid' => 'uuid-1',
                'email' => 'admin@ikiraha.com',
                'first_name' => 'John',
                'last_name' => 'Admin',
                'role_name' => 'admin',
                'is_active' => true,
                'is_verified' => true,
                'phone' => '+250788123456',
                'created_at' => '2024-01-01T00:00:00Z',
                'updated_at' => '2024-01-01T00:00:00Z',
            ]
        ],
        'pagination' => [
            'current_page' => 1,
            'total_pages' => 1,
            'total_count' => 1,
            'per_page' => 20,
        ]
    ];
    
    echo json_encode($response);
    exit();
}

// Alternative: Simple CORS headers (add to every API file)
/*
header("Access-Control-Allow-Origin: http://localhost:52695");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Allow-Credentials: true");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
*/

?>
