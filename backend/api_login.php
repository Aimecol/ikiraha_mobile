<?php
// Simplified User Login API
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
    if (!isset($input['email']) || !isset($input['password'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Email and password are required']);
        exit();
    }

    $email = trim($input['email']);
    $password = $input['password'];

    if (empty($email) || empty($password)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Email and password cannot be empty']);
        exit();
    }

    // Database connection
    $host = 'localhost';
    $database = 'ikiraha_ordering_system';
    $username = 'root';
    $dbPassword = '';
    
    $dsn = "mysql:host=$host;dbname=$database;charset=utf8mb4";
    $pdo = new PDO($dsn, $username, $dbPassword, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    // Get user by email
    $stmt = $pdo->prepare("
        SELECT u.*, ur.name as role_name 
        FROM users u 
        JOIN user_roles ur ON u.role_id = ur.id 
        WHERE u.email = ?
    ");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if (!$user) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Invalid email or password']);
        exit();
    }

    // Check if user is active
    if (!$user['is_active']) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Account is deactivated']);
        exit();
    }

    // Verify password
    if (!password_verify($password, $user['password_hash'])) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Invalid email or password']);
        exit();
    }

    // Update last login time
    $stmt = $pdo->prepare("UPDATE users SET last_login_at = NOW() WHERE id = ?");
    $stmt->execute([$user['id']]);

    // Generate simple token (in production, use proper JWT)
    $token = base64_encode($user['id'] . ':' . time() . ':' . bin2hex(random_bytes(16)));

    // Remove password from response
    unset($user['password_hash']);

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Login successful',
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
