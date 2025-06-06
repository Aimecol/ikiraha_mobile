<?php
/**
 * Authentication API Endpoint
 * Handles login, logout, and token validation
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

// Get request body for POST requests
$input = json_decode(file_get_contents('php://input'), true);

// Mock user credentials for development
$mock_credentials = [
    'admin@ikiraha.com' => [
        'password' => 'admin123',
        'user' => [
            'id' => 1,
            'username' => 'admin',
            'email' => 'admin@ikiraha.com',
            'role' => 'super_admin',
            'full_name' => 'System Administrator',
            'phone' => '+250788123456',
            'status' => 'active'
        ]
    ],
    'manager@restaurant1.com' => [
        'password' => 'manager123',
        'user' => [
            'id' => 2,
            'username' => 'manager1',
            'email' => 'manager@restaurant1.com',
            'role' => 'restaurant_manager',
            'full_name' => 'John Manager',
            'phone' => '+250788123457',
            'status' => 'active',
            'restaurant_id' => 1
        ]
    ],
    'owner@restaurant1.com' => [
        'password' => 'owner123',
        'user' => [
            'id' => 3,
            'username' => 'owner1',
            'email' => 'owner@restaurant1.com',
            'role' => 'restaurant_owner',
            'full_name' => 'Jane Owner',
            'phone' => '+250788123458',
            'status' => 'active',
            'restaurant_id' => 1
        ]
    ],
    'driver1@ikiraha.com' => [
        'password' => 'driver123',
        'user' => [
            'id' => 4,
            'username' => 'driver1',
            'email' => 'driver1@ikiraha.com',
            'role' => 'delivery_driver',
            'full_name' => 'Mike Driver',
            'phone' => '+250788123459',
            'status' => 'active',
            'vehicle_type' => 'motorcycle',
            'license_number' => 'DL123456'
        ]
    ],
    'customer1@email.com' => [
        'password' => 'customer123',
        'user' => [
            'id' => 5,
            'username' => 'customer1',
            'email' => 'customer1@email.com',
            'role' => 'customer',
            'full_name' => 'Alice Customer',
            'phone' => '+250788123460',
            'status' => 'active',
            'address' => 'Kigali, Rwanda'
        ]
    ]
];

// Simple token generation function
function generateToken($user_id) {
    return base64_encode($user_id . ':' . time() . ':' . md5($user_id . time() . 'secret_key'));
}

// Route handling
switch ($method) {
    case 'POST':
        if ($path === '/auth/login') {
            // Login endpoint
            if (!$input || !isset($input['email']) || !isset($input['password'])) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Email and password are required'
                ]);
                break;
            }
            
            $email = $input['email'];
            $password = $input['password'];
            
            if (isset($mock_credentials[$email]) && $mock_credentials[$email]['password'] === $password) {
                $user = $mock_credentials[$email]['user'];
                $token = generateToken($user['id']);
                
                echo json_encode([
                    'success' => true,
                    'message' => 'Login successful',
                    'data' => [
                        'user' => $user,
                        'token' => $token,
                        'expires_in' => 86400 // 24 hours
                    ]
                ]);
            } else {
                http_response_code(401);
                echo json_encode([
                    'success' => false,
                    'message' => 'Invalid email or password'
                ]);
            }
        } elseif ($path === '/auth/register') {
            // Register endpoint
            if (!$input || !isset($input['email']) || !isset($input['password']) || !isset($input['full_name'])) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Email, password, and full name are required'
                ]);
                break;
            }
            
            // Check if email already exists
            if (isset($mock_credentials[$input['email']])) {
                http_response_code(409);
                echo json_encode([
                    'success' => false,
                    'message' => 'Email already exists'
                ]);
                break;
            }
            
            // Simulate user registration
            $new_user = [
                'id' => count($mock_credentials) + 1,
                'username' => $input['username'] ?? explode('@', $input['email'])[0],
                'email' => $input['email'],
                'role' => $input['role'] ?? 'customer',
                'full_name' => $input['full_name'],
                'phone' => $input['phone'] ?? '',
                'status' => 'active'
            ];
            
            $token = generateToken($new_user['id']);
            
            http_response_code(201);
            echo json_encode([
                'success' => true,
                'message' => 'Registration successful',
                'data' => [
                    'user' => $new_user,
                    'token' => $token,
                    'expires_in' => 86400
                ]
            ]);
        } elseif ($path === '/auth/logout') {
            // Logout endpoint
            echo json_encode([
                'success' => true,
                'message' => 'Logout successful'
            ]);
        } else {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'Auth endpoint not found'
            ]);
        }
        break;
        
    case 'GET':
        if ($path === '/auth/me') {
            // Get current user info from token
            $headers = getallheaders();
            $auth_header = isset($headers['Authorization']) ? $headers['Authorization'] : '';
            
            if (strpos($auth_header, 'Bearer ') === 0) {
                $token = substr($auth_header, 7);
                $decoded = base64_decode($token);
                $parts = explode(':', $decoded);
                
                if (count($parts) >= 2) {
                    $user_id = (int)$parts[0];
                    
                    // Find user by ID
                    foreach ($mock_credentials as $cred) {
                        if ($cred['user']['id'] === $user_id) {
                            echo json_encode([
                                'success' => true,
                                'data' => $cred['user']
                            ]);
                            exit;
                        }
                    }
                }
            }
            
            http_response_code(401);
            echo json_encode([
                'success' => false,
                'message' => 'Invalid or missing token'
            ]);
        } else {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'Auth endpoint not found'
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
