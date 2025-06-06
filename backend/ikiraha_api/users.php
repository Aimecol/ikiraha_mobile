<?php
/**
 * Users API Endpoint
 * Handles user management operations
 */

// Enable CORS for all origins (adjust for production)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Accept");
header("Access-Control-Max-Age: 86400");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Get the request method and path
$method = $_SERVER['REQUEST_METHOD'];
$request_uri = $_SERVER['REQUEST_URI'];
$path = parse_url($request_uri, PHP_URL_PATH);
$path = str_replace('/ikiraha_api', '', $path);

// Parse query parameters
$query_params = [];
parse_str($_SERVER['QUERY_STRING'], $query_params);

// Get request body for POST/PUT requests
$input = json_decode(file_get_contents('php://input'), true);

// Mock user data for development
$mock_users = [
    [
        'id' => 1,
        'username' => 'admin',
        'email' => 'admin@ikiraha.com',
        'role' => 'super_admin',
        'full_name' => 'System Administrator',
        'phone' => '+250788123456',
        'status' => 'active',
        'created_at' => '2024-01-01 10:00:00',
        'last_login' => '2024-01-15 14:30:00'
    ],
    [
        'id' => 2,
        'username' => 'manager1',
        'email' => 'manager@restaurant1.com',
        'role' => 'restaurant_manager',
        'full_name' => 'John Manager',
        'phone' => '+250788123457',
        'status' => 'active',
        'restaurant_id' => 1,
        'created_at' => '2024-01-02 09:00:00',
        'last_login' => '2024-01-15 13:45:00'
    ],
    [
        'id' => 3,
        'username' => 'owner1',
        'email' => 'owner@restaurant1.com',
        'role' => 'restaurant_owner',
        'full_name' => 'Jane Owner',
        'phone' => '+250788123458',
        'status' => 'active',
        'restaurant_id' => 1,
        'created_at' => '2024-01-03 08:00:00',
        'last_login' => '2024-01-15 12:20:00'
    ],
    [
        'id' => 4,
        'username' => 'driver1',
        'email' => 'driver1@ikiraha.com',
        'role' => 'delivery_driver',
        'full_name' => 'Mike Driver',
        'phone' => '+250788123459',
        'status' => 'active',
        'vehicle_type' => 'motorcycle',
        'license_number' => 'DL123456',
        'created_at' => '2024-01-04 07:00:00',
        'last_login' => '2024-01-15 11:10:00'
    ],
    [
        'id' => 5,
        'username' => 'customer1',
        'email' => 'customer1@email.com',
        'role' => 'customer',
        'full_name' => 'Alice Customer',
        'phone' => '+250788123460',
        'status' => 'active',
        'address' => 'Kigali, Rwanda',
        'created_at' => '2024-01-05 06:00:00',
        'last_login' => '2024-01-15 10:30:00'
    ]
];

// Route handling
switch ($method) {
    case 'GET':
        if (preg_match('/^\/users\/(\d+)$/', $path, $matches)) {
            // Get specific user
            $user_id = (int)$matches[1];
            $user = array_filter($mock_users, function($u) use ($user_id) {
                return $u['id'] === $user_id;
            });
            
            if ($user) {
                echo json_encode([
                    'success' => true,
                    'data' => array_values($user)[0]
                ]);
            } else {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'message' => 'User not found'
                ]);
            }
        } else {
            // Get all users with pagination
            $page = isset($query_params['page']) ? (int)$query_params['page'] : 1;
            $limit = isset($query_params['limit']) ? (int)$query_params['limit'] : 20;
            $role = isset($query_params['role']) ? $query_params['role'] : null;
            $status = isset($query_params['status']) ? $query_params['status'] : null;
            
            // Filter users
            $filtered_users = $mock_users;
            
            if ($role) {
                $filtered_users = array_filter($filtered_users, function($u) use ($role) {
                    return $u['role'] === $role;
                });
            }
            
            if ($status) {
                $filtered_users = array_filter($filtered_users, function($u) use ($status) {
                    return $u['status'] === $status;
                });
            }
            
            // Pagination
            $total = count($filtered_users);
            $offset = ($page - 1) * $limit;
            $paginated_users = array_slice($filtered_users, $offset, $limit);
            
            echo json_encode([
                'success' => true,
                'data' => array_values($paginated_users),
                'pagination' => [
                    'current_page' => $page,
                    'per_page' => $limit,
                    'total' => $total,
                    'total_pages' => ceil($total / $limit)
                ]
            ]);
        }
        break;
        
    case 'POST':
        // Create new user
        if (!$input) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'Invalid input data'
            ]);
            break;
        }
        
        // Simulate user creation
        $new_user = [
            'id' => count($mock_users) + 1,
            'username' => $input['username'] ?? '',
            'email' => $input['email'] ?? '',
            'role' => $input['role'] ?? 'customer',
            'full_name' => $input['full_name'] ?? '',
            'phone' => $input['phone'] ?? '',
            'status' => 'active',
            'created_at' => date('Y-m-d H:i:s'),
            'last_login' => null
        ];
        
        http_response_code(201);
        echo json_encode([
            'success' => true,
            'message' => 'User created successfully',
            'data' => $new_user
        ]);
        break;
        
    case 'PUT':
        if (preg_match('/^\/users\/(\d+)$/', $path, $matches)) {
            $user_id = (int)$matches[1];
            
            if (!$input) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Invalid input data'
                ]);
                break;
            }
            
            // Simulate user update
            echo json_encode([
                'success' => true,
                'message' => 'User updated successfully',
                'data' => array_merge(['id' => $user_id], $input)
            ]);
        } else {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'User ID required for update'
            ]);
        }
        break;
        
    case 'DELETE':
        if (preg_match('/^\/users\/(\d+)$/', $path, $matches)) {
            $user_id = (int)$matches[1];
            
            // Simulate user deletion
            echo json_encode([
                'success' => true,
                'message' => 'User deleted successfully'
            ]);
        } else {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'User ID required for deletion'
            ]);
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode([
            'success' => false,
            'message' => 'Method not allowed'
        ]);
        break;
}
?>
