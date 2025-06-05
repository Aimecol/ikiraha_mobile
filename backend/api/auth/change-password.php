<?php
/**
 * Change Password API Endpoint
 * POST /api/auth/change-password.php
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
require_once __DIR__ . '/../middleware/auth_middleware.php';

try {
    // Authenticate user
    $authResult = authenticateUser();
    if (!$authResult['success']) {
        http_response_code(401);
        echo json_encode($authResult);
        exit();
    }

    $userId = $authResult['user_id'];

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
    if (!isset($input['current_password']) || !isset($input['new_password'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Current password and new password are required'
        ]);
        exit();
    }

    $currentPassword = $input['current_password'];
    $newPassword = $input['new_password'];

    // Basic validation
    if (empty($currentPassword) || empty($newPassword)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Passwords cannot be empty'
        ]);
        exit();
    }

    // Initialize auth service
    $authService = new AuthService();
    
    // Change password
    $result = $authService->changePassword($userId, $currentPassword, $newPassword);

    // Set appropriate HTTP status code
    if ($result['success']) {
        http_response_code(200);
        
        // Log password change
        error_log("Password changed successfully for user ID: " . $userId);
    } else {
        http_response_code(400);
        
        // Log failed password change
        error_log("Password change failed for user ID: " . $userId . " - " . $result['message']);
    }

    // Return response
    echo json_encode($result);

} catch (Exception $e) {
    // Log error
    error_log("Change password API error: " . $e->getMessage());
    
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Internal server error',
        'error' => $e->getMessage() // Remove in production
    ]);
}
?>
