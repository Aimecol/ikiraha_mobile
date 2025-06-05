<?php
/**
 * User Registration API Endpoint
 * POST /api/auth/register.php
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

    // Sanitize input data
    $userData = [
        'first_name' => DatabaseUtils::sanitizeInput($input['first_name']),
        'last_name' => DatabaseUtils::sanitizeInput($input['last_name']),
        'email' => strtolower(trim($input['email'])),
        'phone' => DatabaseUtils::sanitizeInput($input['phone']),
        'password' => $input['password'] // Don't sanitize password as it may contain special characters
    ];

    // Optional fields
    if (isset($input['date_of_birth']) && !empty($input['date_of_birth'])) {
        $userData['date_of_birth'] = $input['date_of_birth'];
    }
    
    if (isset($input['gender']) && !empty($input['gender'])) {
        $userData['gender'] = $input['gender'];
    }

    // Initialize auth service
    $authService = new AuthService();
    
    // Register user
    $result = $authService->register($userData);

    // Set appropriate HTTP status code
    if ($result['success']) {
        http_response_code(201); // Created
        
        // Log successful registration (in production, use proper logging)
        error_log("User registered successfully: " . $userData['email']);
    } else {
        http_response_code(400); // Bad Request
        
        // Log failed registration attempt
        error_log("Registration failed for email: " . $userData['email'] . " - " . $result['message']);
    }

    // Return response
    echo json_encode($result);

} catch (Exception $e) {
    // Log error
    error_log("Registration API error: " . $e->getMessage());
    
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Internal server error',
        'error' => $e->getMessage() // Remove in production
    ]);
}
?>
