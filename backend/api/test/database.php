<?php
/**
 * Database Connection Test API Endpoint
 * GET /api/test/database.php
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only allow GET requests
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed. Use GET.'
    ]);
    exit();
}

require_once __DIR__ . '/../../config/database.php';

try {
    // Test database connection
    $db = new Database();
    $connectionTest = $db->testConnection();
    
    if ($connectionTest['success']) {
        // Get database info
        $dbInfo = $db->getDatabaseInfo();
        
        // Check if required tables exist
        $requiredTables = [
            'users', 'user_roles', 'languages', 'restaurants', 
            'products', 'orders', 'order_items'
        ];
        
        $existingTables = [];
        $missingTables = [];
        
        foreach ($requiredTables as $table) {
            if ($db->tableExists($table)) {
                $existingTables[] = $table;
            } else {
                $missingTables[] = $table;
            }
        }
        
        // Get user roles count
        $rolesCount = $db->single("SELECT COUNT(*) as count FROM user_roles");
        
        // Get users count
        $usersCount = $db->single("SELECT COUNT(*) as count FROM users");
        
        $response = [
            'success' => true,
            'message' => 'Database connection successful',
            'database_info' => $dbInfo,
            'connection_test' => $connectionTest,
            'tables_check' => [
                'required_tables' => $requiredTables,
                'existing_tables' => $existingTables,
                'missing_tables' => $missingTables,
                'all_required_exist' => empty($missingTables)
            ],
            'data_check' => [
                'user_roles_count' => $rolesCount['count'] ?? 0,
                'users_count' => $usersCount['count'] ?? 0
            ],
            'server_info' => [
                'php_version' => phpversion(),
                'server_time' => date('Y-m-d H:i:s'),
                'timezone' => date_default_timezone_get()
            ]
        ];
        
        http_response_code(200);
        echo json_encode($response);
        
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Database connection failed',
            'error' => $connectionTest['message']
        ]);
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database test failed',
        'error' => $e->getMessage()
    ]);
}
?>
