<?php
/**
 * Restaurants API Endpoint with CORS Support
 * Handles restaurant management operations for Ikiraha Mobile
 */

// Enable CORS for all origins (adjust for production)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Include database configuration
require_once __DIR__ . '/../config/database.php';

try {
    // Initialize database connection
    $database = new Database();
    $db = $database->getConnection();
    
    // Get request method and parse request
    $method = $_SERVER['REQUEST_METHOD'];
    $request_uri = $_SERVER['REQUEST_URI'];
    
    // Parse query parameters
    $query_params = [];
    if (isset($_SERVER['QUERY_STRING'])) {
        parse_str($_SERVER['QUERY_STRING'], $query_params);
    }
    
    // Get JSON input for POST/PUT requests
    $input = json_decode(file_get_contents('php://input'), true);
    
    switch ($method) {
        case 'GET':
            handleGetRestaurants($db, $query_params);
            break;
            
        case 'POST':
            handleCreateRestaurant($db, $input);
            break;
            
        case 'PUT':
            handleUpdateRestaurant($db, $input, $query_params);
            break;
            
        case 'DELETE':
            handleDeleteRestaurant($db, $query_params);
            break;
            
        default:
            http_response_code(405);
            echo json_encode([
                'success' => false,
                'message' => 'Method not allowed'
            ]);
            break;
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Server error: ' . $e->getMessage()
    ]);
}

/**
 * Handle GET requests - Fetch restaurants
 */
function handleGetRestaurants($db, $params) {
    try {
        // Build query with filters
        $sql = "SELECT 
                    r.*,
                    rc.name as category_name,
                    CONCAT(u.first_name, ' ', u.last_name) as owner_name
                FROM restaurants r
                LEFT JOIN restaurant_categories rc ON r.category_id = rc.id
                LEFT JOIN users u ON r.owner_id = u.id
                WHERE 1=1";
        
        $bind_params = [];
        
        // Add search filter
        if (!empty($params['search'])) {
            $sql .= " AND (r.name LIKE ? OR r.email LIKE ? OR r.description LIKE ?)";
            $search_term = '%' . $params['search'] . '%';
            $bind_params[] = $search_term;
            $bind_params[] = $search_term;
            $bind_params[] = $search_term;
        }
        
        // Add category filter
        if (!empty($params['category']) && $params['category'] !== 'all') {
            $sql .= " AND rc.name = ?";
            $bind_params[] = $params['category'];
        }
        
        // Add status filter
        if (!empty($params['status']) && $params['status'] !== 'all') {
            switch ($params['status']) {
                case 'active':
                    $sql .= " AND r.is_active = 1";
                    break;
                case 'inactive':
                    $sql .= " AND r.is_active = 0";
                    break;
                case 'open':
                    $sql .= " AND r.is_open = 1";
                    break;
                case 'closed':
                    $sql .= " AND r.is_open = 0";
                    break;
            }
        }
        
        // Add pagination
        $page = isset($params['page']) ? (int)$params['page'] : 1;
        $limit = isset($params['limit']) ? (int)$params['limit'] : 20;
        $offset = ($page - 1) * $limit;
        
        $sql .= " ORDER BY r.created_at DESC LIMIT ? OFFSET ?";
        $bind_params[] = $limit;
        $bind_params[] = $offset;
        
        // Execute query
        $stmt = $db->prepare($sql);
        $stmt->execute($bind_params);
        $restaurants = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Get total count for pagination
        $count_sql = "SELECT COUNT(*) as total FROM restaurants r
                      LEFT JOIN restaurant_categories rc ON r.category_id = rc.id
                      WHERE 1=1";
        
        if (!empty($params['search'])) {
            $count_sql .= " AND (r.name LIKE ? OR r.email LIKE ? OR r.description LIKE ?)";
        }
        
        if (!empty($params['category']) && $params['category'] !== 'all') {
            $count_sql .= " AND rc.name = ?";
        }
        
        $count_stmt = $db->prepare($count_sql);
        $count_params = [];
        
        if (!empty($params['search'])) {
            $search_term = '%' . $params['search'] . '%';
            $count_params[] = $search_term;
            $count_params[] = $search_term;
            $count_params[] = $search_term;
        }
        
        if (!empty($params['category']) && $params['category'] !== 'all') {
            $count_params[] = $params['category'];
        }
        
        $count_stmt->execute($count_params);
        $total = $count_stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        // Return response
        echo json_encode([
            'success' => true,
            'data' => $restaurants,
            'pagination' => [
                'current_page' => $page,
                'total_pages' => ceil($total / $limit),
                'total_count' => (int)$total,
                'per_page' => $limit
            ]
        ]);
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Error fetching restaurants: ' . $e->getMessage()
        ]);
    }
}

/**
 * Handle POST requests - Create restaurant
 */
function handleCreateRestaurant($db, $input) {
    // Implementation for creating restaurants
    echo json_encode([
        'success' => false,
        'message' => 'Create restaurant functionality coming soon'
    ]);
}

/**
 * Handle PUT requests - Update restaurant
 */
function handleUpdateRestaurant($db, $input, $params) {
    // Implementation for updating restaurants
    echo json_encode([
        'success' => false,
        'message' => 'Update restaurant functionality coming soon'
    ]);
}

/**
 * Handle DELETE requests - Delete restaurant
 */
function handleDeleteRestaurant($db, $params) {
    // Implementation for deleting restaurants
    echo json_encode([
        'success' => false,
        'message' => 'Delete restaurant functionality coming soon'
    ]);
}
?>
