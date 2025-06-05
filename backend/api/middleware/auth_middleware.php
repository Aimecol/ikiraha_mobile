<?php
/**
 * Authentication Middleware
 * Validates JWT tokens and provides user authentication for protected routes
 */

require_once __DIR__ . '/../../services/AuthService.php';

/**
 * Authenticate user from Authorization header
 * Returns user data if authentication is successful
 */
function authenticateUser() {
    try {
        // Get token from Authorization header
        $token = getBearerToken();
        
        if (!$token) {
            return [
                'success' => false,
                'message' => 'Authorization token is required'
            ];
        }

        // Validate token
        $authService = new AuthService();
        $result = $authService->validateToken($token);

        if ($result['success']) {
            return [
                'success' => true,
                'user_id' => $result['data']['user']['id'],
                'user' => $result['data']['user'],
                'token_data' => $result['data']['token_data']
            ];
        } else {
            return $result;
        }

    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => 'Authentication failed: ' . $e->getMessage()
        ];
    }
}

/**
 * Get Bearer token from Authorization header
 */
function getBearerToken() {
    $headers = getallheaders();
    
    // Check for Authorization header
    if (isset($headers['Authorization'])) {
        $authHeader = $headers['Authorization'];
        
        // Extract token from "Bearer <token>" format
        if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            return $matches[1];
        }
    }
    
    return null;
}

/**
 * Require authentication for a route
 * Call this function at the beginning of protected endpoints
 */
function requireAuth() {
    $authResult = authenticateUser();
    
    if (!$authResult['success']) {
        http_response_code(401);
        header('Content-Type: application/json');
        echo json_encode($authResult);
        exit();
    }
    
    return $authResult;
}

/**
 * Check if user has specific role
 */
function requireRole($requiredRole) {
    $authResult = requireAuth();
    $userRole = $authResult['user']['role_name'];
    
    if ($userRole !== $requiredRole) {
        http_response_code(403);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'message' => 'Insufficient permissions. Required role: ' . $requiredRole
        ]);
        exit();
    }
    
    return $authResult;
}

/**
 * Check if user has any of the specified roles
 */
function requireAnyRole($allowedRoles) {
    $authResult = requireAuth();
    $userRole = $authResult['user']['role_name'];
    
    if (!in_array($userRole, $allowedRoles)) {
        http_response_code(403);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'message' => 'Insufficient permissions. Required roles: ' . implode(', ', $allowedRoles)
        ]);
        exit();
    }
    
    return $authResult;
}

/**
 * Check if user is admin
 */
function requireAdmin() {
    return requireAnyRole(['super_admin', 'admin']);
}

/**
 * Check if user is restaurant owner or admin
 */
function requireRestaurantOwnerOrAdmin() {
    return requireAnyRole(['super_admin', 'admin', 'restaurant_owner']);
}

/**
 * Optional authentication - doesn't exit if no auth provided
 * Returns null if no authentication, user data if authenticated
 */
function optionalAuth() {
    try {
        $token = getBearerToken();
        
        if (!$token) {
            return null;
        }

        $authService = new AuthService();
        $result = $authService->validateToken($token);

        if ($result['success']) {
            return [
                'user_id' => $result['data']['user']['id'],
                'user' => $result['data']['user'],
                'token_data' => $result['data']['token_data']
            ];
        }
        
        return null;

    } catch (Exception $e) {
        return null;
    }
}

/**
 * Rate limiting helper (basic implementation)
 */
function checkRateLimit($identifier, $maxRequests = 60, $timeWindow = 3600) {
    // This is a basic implementation - in production, use Redis or database
    $rateLimitFile = sys_get_temp_dir() . '/rate_limit_' . md5($identifier);
    
    $currentTime = time();
    $requests = [];
    
    // Load existing requests
    if (file_exists($rateLimitFile)) {
        $data = file_get_contents($rateLimitFile);
        $requests = json_decode($data, true) ?: [];
    }
    
    // Remove old requests outside time window
    $requests = array_filter($requests, function($timestamp) use ($currentTime, $timeWindow) {
        return ($currentTime - $timestamp) < $timeWindow;
    });
    
    // Check if limit exceeded
    if (count($requests) >= $maxRequests) {
        return false;
    }
    
    // Add current request
    $requests[] = $currentTime;
    
    // Save updated requests
    file_put_contents($rateLimitFile, json_encode($requests));
    
    return true;
}

/**
 * Apply rate limiting
 */
function applyRateLimit($identifier, $maxRequests = 60, $timeWindow = 3600) {
    if (!checkRateLimit($identifier, $maxRequests, $timeWindow)) {
        http_response_code(429);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'message' => 'Rate limit exceeded. Please try again later.'
        ]);
        exit();
    }
}

/**
 * Log API access
 */
function logApiAccess($endpoint, $method, $userId = null, $ip = null) {
    $ip = $ip ?: $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';
    $timestamp = date('Y-m-d H:i:s');
    
    $logEntry = [
        'timestamp' => $timestamp,
        'endpoint' => $endpoint,
        'method' => $method,
        'user_id' => $userId,
        'ip' => $ip,
        'user_agent' => $userAgent
    ];
    
    // In production, log to database or proper logging system
    error_log("API Access: " . json_encode($logEntry));
}
?>
