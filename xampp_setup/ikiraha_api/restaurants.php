<?php
/**
 * Restaurants API Endpoint
 * Handles restaurant management operations
 */

// Enable CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'];

// For now, return mock data since we don't have the database set up
// This will allow the Flutter app to work immediately

if ($method === 'GET') {
    // Parse query parameters
    $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
    $search = isset($_GET['search']) ? $_GET['search'] : '';
    $category = isset($_GET['category']) ? $_GET['category'] : '';
    $status = isset($_GET['status']) ? $_GET['status'] : '';

    // Mock restaurant data
    $restaurants = [
        [
            'id' => 1,
            'uuid' => 'rest-uuid-1',
            'owner_id' => 3,
            'category_id' => 2,
            'name' => 'Pizza Palace',
            'slug' => 'pizza-palace',
            'description' => 'Authentic Italian pizza with fresh ingredients and traditional recipes.',
            'logo' => 'https://example.com/logos/pizza-palace.jpg',
            'cover_image' => 'https://example.com/covers/pizza-palace.jpg',
            'phone' => '+250788123456',
            'email' => 'info@pizzapalace.com',
            'website' => 'https://pizzapalace.com',
            'address_line_1' => '123 Main Street',
            'address_line_2' => 'Downtown',
            'city' => 'Kigali',
            'state' => 'Kigali Province',
            'postal_code' => '00100',
            'country' => 'Rwanda',
            'latitude' => -1.9441,
            'longitude' => 30.0619,
            'delivery_radius' => 15.0,
            'minimum_order_amount' => 10.0,
            'delivery_fee' => 2.5,
            'estimated_delivery_time' => 30,
            'rating' => 4.5,
            'total_reviews' => 120,
            'is_featured' => true,
            'is_active' => true,
            'is_open' => true,
            'created_at' => '2024-01-01T00:00:00Z',
            'updated_at' => '2024-01-01T00:00:00Z',
            'category_name' => 'Pizza',
            'owner_name' => 'Jane Restaurant',
        ],
        [
            'id' => 2,
            'uuid' => 'rest-uuid-2',
            'owner_id' => 3,
            'category_id' => 1,
            'name' => 'Burger House',
            'slug' => 'burger-house',
            'description' => 'Delicious burgers and fast food with quality ingredients.',
            'logo' => 'https://example.com/logos/burger-house.jpg',
            'cover_image' => 'https://example.com/covers/burger-house.jpg',
            'phone' => '+250788654321',
            'email' => 'contact@burgerhouse.com',
            'website' => 'https://burgerhouse.com',
            'address_line_1' => '456 Food Street',
            'address_line_2' => 'City Center',
            'city' => 'Kigali',
            'state' => 'Kigali Province',
            'postal_code' => '00200',
            'country' => 'Rwanda',
            'latitude' => -1.9506,
            'longitude' => 30.0588,
            'delivery_radius' => 12.0,
            'minimum_order_amount' => 8.0,
            'delivery_fee' => 2.0,
            'estimated_delivery_time' => 25,
            'rating' => 4.2,
            'total_reviews' => 85,
            'is_featured' => false,
            'is_active' => true,
            'is_open' => false,
            'created_at' => '2024-01-02T00:00:00Z',
            'updated_at' => '2024-01-02T00:00:00Z',
            'category_name' => 'Fast Food',
            'owner_name' => 'Jane Restaurant',
        ],
        [
            'id' => 3,
            'uuid' => 'rest-uuid-3',
            'owner_id' => 4,
            'category_id' => 3,
            'name' => 'Sushi Zen',
            'slug' => 'sushi-zen',
            'description' => 'Premium Japanese cuisine with fresh sushi and traditional dishes.',
            'logo' => 'https://example.com/logos/sushi-zen.jpg',
            'cover_image' => 'https://example.com/covers/sushi-zen.jpg',
            'phone' => '+250788987654',
            'email' => 'hello@sushizen.com',
            'website' => 'https://sushizen.com',
            'address_line_1' => '789 Asian Avenue',
            'address_line_2' => 'Kimihurura',
            'city' => 'Kigali',
            'state' => 'Kigali Province',
            'postal_code' => '00300',
            'country' => 'Rwanda',
            'latitude' => -1.9355,
            'longitude' => 30.0928,
            'delivery_radius' => 20.0,
            'minimum_order_amount' => 15.0,
            'delivery_fee' => 3.0,
            'estimated_delivery_time' => 40,
            'rating' => 4.8,
            'total_reviews' => 200,
            'is_featured' => true,
            'is_active' => false,
            'is_open' => false,
            'created_at' => '2024-01-03T00:00:00Z',
            'updated_at' => '2024-01-03T00:00:00Z',
            'category_name' => 'Asian',
            'owner_name' => 'Mike Manager',
        ],
        [
            'id' => 4,
            'uuid' => 'rest-uuid-4',
            'owner_id' => 3,
            'category_id' => 4,
            'name' => 'Mama Mia Italian',
            'slug' => 'mama-mia-italian',
            'description' => 'Traditional Italian restaurant with pasta, risotto, and wine.',
            'logo' => 'https://example.com/logos/mama-mia.jpg',
            'cover_image' => 'https://example.com/covers/mama-mia.jpg',
            'phone' => '+250788111222',
            'email' => 'info@mamamia.com',
            'website' => 'https://mamamia.com',
            'address_line_1' => '321 Italian Street',
            'address_line_2' => 'Nyarutarama',
            'city' => 'Kigali',
            'state' => 'Kigali Province',
            'postal_code' => '00400',
            'country' => 'Rwanda',
            'latitude' => -1.9282,
            'longitude' => 30.1127,
            'delivery_radius' => 18.0,
            'minimum_order_amount' => 12.0,
            'delivery_fee' => 2.8,
            'estimated_delivery_time' => 35,
            'rating' => 4.6,
            'total_reviews' => 150,
            'is_featured' => false,
            'is_active' => true,
            'is_open' => true,
            'created_at' => '2024-01-04T00:00:00Z',
            'updated_at' => '2024-01-04T00:00:00Z',
            'category_name' => 'Italian',
            'owner_name' => 'Jane Restaurant',
        ],
        [
            'id' => 5,
            'uuid' => 'rest-uuid-5',
            'owner_id' => 4,
            'category_id' => 7,
            'name' => 'Green Garden Healthy',
            'slug' => 'green-garden-healthy',
            'description' => 'Fresh, organic, and healthy meals for a balanced lifestyle.',
            'logo' => 'https://example.com/logos/green-garden.jpg',
            'cover_image' => 'https://example.com/covers/green-garden.jpg',
            'phone' => '+250788333444',
            'email' => 'hello@greengarden.com',
            'website' => 'https://greengarden.com',
            'address_line_1' => '654 Health Avenue',
            'address_line_2' => 'Remera',
            'city' => 'Kigali',
            'state' => 'Kigali Province',
            'postal_code' => '00500',
            'country' => 'Rwanda',
            'latitude' => -1.9578,
            'longitude' => 30.1086,
            'delivery_radius' => 14.0,
            'minimum_order_amount' => 9.0,
            'delivery_fee' => 2.2,
            'estimated_delivery_time' => 28,
            'rating' => 4.4,
            'total_reviews' => 95,
            'is_featured' => false,
            'is_active' => true,
            'is_open' => true,
            'created_at' => '2024-01-05T00:00:00Z',
            'updated_at' => '2024-01-05T00:00:00Z',
            'category_name' => 'Healthy',
            'owner_name' => 'Mike Manager',
        ],
    ];

    // Apply filters
    $filtered_restaurants = $restaurants;

    if (!empty($search)) {
        $filtered_restaurants = array_filter($filtered_restaurants, function($restaurant) use ($search) {
            return stripos($restaurant['name'], $search) !== false ||
                   stripos($restaurant['email'], $search) !== false ||
                   stripos($restaurant['description'], $search) !== false;
        });
    }

    if (!empty($category) && $category !== 'all') {
        $filtered_restaurants = array_filter($filtered_restaurants, function($restaurant) use ($category) {
            return $restaurant['category_name'] === $category;
        });
    }

    if (!empty($status) && $status !== 'all') {
        $filtered_restaurants = array_filter($filtered_restaurants, function($restaurant) use ($status) {
            switch ($status) {
                case 'active':
                    return $restaurant['is_active'] === true;
                case 'inactive':
                    return $restaurant['is_active'] === false;
                case 'open':
                    return $restaurant['is_open'] === true;
                case 'closed':
                    return $restaurant['is_open'] === false;
                default:
                    return true;
            }
        });
    }

    // Reset array keys
    $filtered_restaurants = array_values($filtered_restaurants);

    // Return response
    echo json_encode([
        'success' => true,
        'data' => $filtered_restaurants,
        'pagination' => [
            'current_page' => $page,
            'total_pages' => 1,
            'total_count' => count($filtered_restaurants),
            'per_page' => $limit,
        ],
        'timestamp' => date('Y-m-d H:i:s')
    ]);

} elseif ($method === 'PUT') {
    // Handle status updates
    $input = json_decode(file_get_contents('php://input'), true);
    
    echo json_encode([
        'success' => true,
        'message' => 'Restaurant updated successfully',
        'timestamp' => date('Y-m-d H:i:s')
    ]);

} else {
    // Handle other methods
    echo json_encode([
        'success' => false,
        'message' => 'Method not implemented yet: ' . $method,
        'timestamp' => date('Y-m-d H:i:s')
    ]);
}
?>
