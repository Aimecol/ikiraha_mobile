<?php
/**
 * User Login API Endpoint
 * POST /api/auth/login.php
 */

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
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed. Use POST.'
    ]);
    exit();
}

require_once __DIR__ . '/../../services/AuthService.php';

try {
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Invalid JSON input'
        ]);
        exit();
    }

    // Validate required fields
    if (!isset($input['email']) || !isset($input['password'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Email and password are required'
        ]);
        exit();
    }

    // Sanitize input
    $email = strtolower(trim($input['email']));
    $password = $input['password'];
    $rememberMe = isset($input['remember_me']) ? (bool)$input['remember_me'] : false;

    // Basic validation
    if (empty($email) || empty($password)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Email and password cannot be empty'
        ]);
        exit();
    }

    // Initialize auth service
    $authService = new AuthService();
    
    // Attempt login
    $result = $authService->login($email, $password, $rememberMe);

    // Set appropriate HTTP status code
    if ($result['success']) {
        http_response_code(200); // OK
        
        // Log successful login
        error_log("User logged in successfully: " . $email);
    } else {
        http_response_code(401); // Unauthorized
        
        // Log failed login attempt
        error_log("Login failed for email: " . $email . " - " . $result['message']);
    }

    // Return response
    echo json_encode($result);

} catch (Exception $e) {
    // Log error
    error_log("Login API error: " . $e->getMessage());
    
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Internal server error',
        'error' => $e->getMessage() // Remove in production
    ]);
}
?>
