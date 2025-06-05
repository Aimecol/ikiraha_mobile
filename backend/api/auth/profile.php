<?php
/**
 * User Profile API Endpoint
 * GET /api/auth/profile.php - Get user profile
 * PUT /api/auth/profile.php - Update user profile
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, PUT, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
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
    $authService = new AuthService();

    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        // Get user profile
        $result = $authService->getUserProfile($userId);
        
        if ($result['success']) {
            http_response_code(200);
        } else {
            http_response_code(404);
        }
        
        echo json_encode($result);

    } elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
        // Update user profile
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (!$input) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'Invalid JSON input'
            ]);
            exit();
        }

        $result = $authService->updateProfile($userId, $input);
        
        if ($result['success']) {
            http_response_code(200);
        } else {
            http_response_code(400);
        }
        
        echo json_encode($result);

    } else {
        http_response_code(405);
        echo json_encode([
            'success' => false,
            'message' => 'Method not allowed'
        ]);
    }

} catch (Exception $e) {
    error_log("Profile API error: " . $e->getMessage());
    
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Internal server error',
        'error' => $e->getMessage()
    ]);
}
?>
