<?php
// Simplified User Registration API
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed. Use POST.']);
    exit();
}

try {
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid JSON input']);
        exit();
    }

    // Validate required fields
    $requiredFields = ['first_name', 'last_name', 'email', 'phone', 'password'];
    $missingFields = [];
    
    foreach ($requiredFields as $field) {
        if (!isset($input[$field]) || empty(trim($input[$field]))) {
            $missingFields[] = $field;
        }
    }

    if (!empty($missingFields)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Missing required fields',
            'missing_fields' => $missingFields
        ]);
        exit();
    }

    // Database connection
    $host = 'localhost';
    $database = 'ikiraha_ordering_system';
    $username = 'root';
    $password = '';
    
    $dsn = "mysql:host=$host;dbname=$database;charset=utf8mb4";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    // Check if user already exists
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$input['email']]);
    if ($stmt->fetch()) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'User with this email already exists']);
        exit();
    }

    // Get customer role ID
    $stmt = $pdo->prepare("SELECT id FROM user_roles WHERE name = 'customer' AND is_active = 1");
    $stmt->execute();
    $role = $stmt->fetch();
    
    if (!$role) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Customer role not found']);
        exit();
    }

    // Generate UUID and hash password
    $uuid = sprintf(
        '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        mt_rand(0, 0xffff), mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),
        mt_rand(0, 0x0fff) | 0x4000,
        mt_rand(0, 0x3fff) | 0x8000,
        mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
    );
    
    $hashedPassword = password_hash($input['password'], PASSWORD_DEFAULT);

    // Insert user
    $stmt = $pdo->prepare("
        INSERT INTO users (uuid, role_id, email, phone, password_hash, first_name, last_name, is_active, created_at) 
        VALUES (?, ?, ?, ?, ?, ?, ?, 1, NOW())
    ");
    
    $stmt->execute([
        $uuid,
        $role['id'],
        $input['email'],
        $input['phone'],
        $hashedPassword,
        $input['first_name'],
        $input['last_name']
    ]);

    $userId = $pdo->lastInsertId();

    // Generate simple token (in production, use proper JWT)
    $token = base64_encode($userId . ':' . time() . ':' . bin2hex(random_bytes(16)));

    // Get user data
    $stmt = $pdo->prepare("
        SELECT u.*, ur.name as role_name 
        FROM users u 
        JOIN user_roles ur ON u.role_id = ur.id 
        WHERE u.id = ?
    ");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    
    // Remove password from response
    unset($user['password_hash']);

    http_response_code(201);
    echo json_encode([
        'success' => true,
        'message' => 'User registered successfully',
        'data' => [
            'user' => $user,
            'token' => $token,
            'expires_in' => 86400
        ]
    ], JSON_PRETTY_PRINT);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error',
        'error' => $e->getMessage()
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Server error',
        'error' => $e->getMessage()
    ]);
}
?>
