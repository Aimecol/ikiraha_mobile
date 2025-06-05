<?php
/**
 * Token Validation API Endpoint
 * POST /api/auth/validate.php
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
    // Get token from Authorization header or request body
    $token = null;
    
    // Check Authorization header first
    $headers = getallheaders();
    if (isset($headers['Authorization'])) {
        $authHeader = $headers['Authorization'];
        if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            $token = $matches[1];
        }
    }
    
    // If no token in header, check request body
    if (!$token) {
        $input = json_decode(file_get_contents('php://input'), true);
        if ($input && isset($input['token'])) {
            $token = $input['token'];
        }
    }

    if (!$token) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Token is required'
        ]);
        exit();
    }

    // Initialize auth service
    $authService = new AuthService();
    
    // Validate token
    $result = $authService->validateToken($token);

    // Set appropriate HTTP status code
    if ($result['success']) {
        http_response_code(200); // OK
    } else {
        http_response_code(401); // Unauthorized
    }

    // Return response
    echo json_encode($result);

} catch (Exception $e) {
    // Log error
    error_log("Token validation API error: " . $e->getMessage());
    
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Internal server error',
        'error' => $e->getMessage() // Remove in production
    ]);
}
?>
