import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/database_config.dart';
import '../models/api_response.dart';
import '../models/restaurant.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Base headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get headers with authentication token
  Map<String, String> _getAuthHeaders(String? token) {
    final headers = Map<String, String>.from(_headers);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Generic API request handler
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final url = Uri.parse(DatabaseConfig.getApiUrl(endpoint));
      final headers = _getAuthHeaders(token);

      if (EnvironmentConfig.enableLogging) {
        print('Making $method request to: $url');
        print('Headers: $headers');
      }

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (EnvironmentConfig.enableLogging) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'API request failed');
      }
    } catch (e) {
      if (EnvironmentConfig.enableLogging) {
        print('Database Service Error: $e');
      }

      // Handle specific CORS errors
      if (e.toString().contains('CORS') ||
          e.toString().contains('Access-Control-Allow-Origin') ||
          e.toString().contains('XMLHttpRequest')) {
        if (EnvironmentConfig.enableLogging) {
          print('CORS error detected, falling back to mock data');
        }
        return _getMockData(endpoint);
      }

      // Return mock data for development when API is not available
      if (EnvironmentConfig.isDevelopment) {
        if (EnvironmentConfig.enableLogging) {
          print('Development mode: Using mock data for endpoint: $endpoint');
        }
        return _getMockData(endpoint);
      }

      rethrow;
    }
  }

  // Mock data for development
  Map<String, dynamic> _getMockData(String endpoint) {
    // Extract the base endpoint without query parameters
    String baseEndpoint = endpoint.split('?')[0];

    // Remove the base API path if present
    if (baseEndpoint.startsWith('/ikiraha_api')) {
      baseEndpoint = baseEndpoint.substring('/ikiraha_api'.length);
    }

    switch (baseEndpoint) {
      case '/users':
        return {
          'success': true,
          'data': [
            {
              'id': 1,
              'uuid': 'uuid-1',
              'email': 'superadmin@ikiraha.com',
              'first_name': 'Super',
              'last_name': 'Admin',
              'role_name': 'super_admin',
              'is_active': true,
              'is_verified': true,
              'phone': '+250788123456',
              'created_at': '2024-01-01T00:00:00Z',
              'updated_at': '2024-01-01T00:00:00Z',
            },
            {
              'id': 2,
              'uuid': 'uuid-2',
              'email': 'admin@ikiraha.com',
              'first_name': 'John',
              'last_name': 'Admin',
              'role_name': 'admin',
              'is_active': true,
              'is_verified': true,
              'phone': '+250788234567',
              'created_at': '2024-01-02T00:00:00Z',
              'updated_at': '2024-01-02T00:00:00Z',
            },
            {
              'id': 3,
              'uuid': 'uuid-3',
              'email': 'restaurant@ikiraha.com',
              'first_name': 'Jane',
              'last_name': 'Restaurant',
              'role_name': 'restaurant_owner',
              'is_active': true,
              'is_verified': true,
              'phone': '+250788345678',
              'created_at': '2024-01-03T00:00:00Z',
              'updated_at': '2024-01-03T00:00:00Z',
            },
            {
              'id': 4,
              'uuid': 'uuid-4',
              'email': 'manager@ikiraha.com',
              'first_name': 'Mike',
              'last_name': 'Manager',
              'role_name': 'restaurant_manager',
              'is_active': true,
              'is_verified': true,
              'phone': '+250788456789',
              'created_at': '2024-01-04T00:00:00Z',
              'updated_at': '2024-01-04T00:00:00Z',
            },
            {
              'id': 5,
              'uuid': 'uuid-5',
              'email': 'driver@ikiraha.com',
              'first_name': 'Bob',
              'last_name': 'Driver',
              'role_name': 'delivery_driver',
              'is_active': true,
              'is_verified': true,
              'phone': '+250788567890',
              'created_at': '2024-01-05T00:00:00Z',
              'updated_at': '2024-01-05T00:00:00Z',
            },
            {
              'id': 6,
              'uuid': 'uuid-6',
              'email': 'customer1@ikiraha.com',
              'first_name': 'Alice',
              'last_name': 'Customer',
              'role_name': 'customer',
              'is_active': true,
              'is_verified': false,
              'phone': '+250788678901',
              'created_at': '2024-01-06T00:00:00Z',
              'updated_at': '2024-01-06T00:00:00Z',
            },
            {
              'id': 7,
              'uuid': 'uuid-7',
              'email': 'customer2@ikiraha.com',
              'first_name': 'David',
              'last_name': 'Smith',
              'role_name': 'customer',
              'is_active': false,
              'is_verified': true,
              'phone': '+250788789012',
              'created_at': '2024-01-07T00:00:00Z',
              'updated_at': '2024-01-07T00:00:00Z',
            },
            {
              'id': 8,
              'uuid': 'uuid-8',
              'email': 'customer3@ikiraha.com',
              'first_name': 'Sarah',
              'last_name': 'Johnson',
              'role_name': 'customer',
              'is_active': true,
              'is_verified': true,
              'phone': '+250788890123',
              'created_at': '2024-01-08T00:00:00Z',
              'updated_at': '2024-01-08T00:00:00Z',
            },
          ],
          'pagination': {
            'current_page': 1,
            'total_pages': 1,
            'total_count': 8,
            'per_page': 20,
          }
        };
      case '/restaurants':
        return {
          'success': true,
          'data': [
            {
              'id': 1,
              'uuid': 'rest-uuid-1',
              'owner_id': 3,
              'category_id': 2,
              'name': 'Pizza Palace',
              'slug': 'pizza-palace',
              'description': 'Authentic Italian pizza with fresh ingredients and traditional recipes.',
              'logo': 'https://example.com/logos/pizza-palace.jpg',
              'cover_image': 'https://example.com/covers/pizza-palace.jpg',
              'phone': '+250788123456',
              'email': 'info@pizzapalace.com',
              'website': 'https://pizzapalace.com',
              'address_line_1': '123 Main Street',
              'address_line_2': 'Downtown',
              'city': 'Kigali',
              'state': 'Kigali Province',
              'postal_code': '00100',
              'country': 'Rwanda',
              'latitude': -1.9441,
              'longitude': 30.0619,
              'delivery_radius': 15.0,
              'minimum_order_amount': 10.0,
              'delivery_fee': 2.5,
              'estimated_delivery_time': 30,
              'rating': 4.5,
              'total_reviews': 120,
              'is_featured': true,
              'is_active': true,
              'is_open': true,
              'created_at': '2024-01-01T00:00:00Z',
              'updated_at': '2024-01-01T00:00:00Z',
              'category_name': 'Pizza',
              'owner_name': 'Jane Restaurant',
            },
            {
              'id': 2,
              'uuid': 'rest-uuid-2',
              'owner_id': 3,
              'category_id': 1,
              'name': 'Burger House',
              'slug': 'burger-house',
              'description': 'Delicious burgers and fast food with quality ingredients.',
              'logo': 'https://example.com/logos/burger-house.jpg',
              'cover_image': 'https://example.com/covers/burger-house.jpg',
              'phone': '+250788654321',
              'email': 'contact@burgerhouse.com',
              'website': 'https://burgerhouse.com',
              'address_line_1': '456 Food Street',
              'address_line_2': 'City Center',
              'city': 'Kigali',
              'state': 'Kigali Province',
              'postal_code': '00200',
              'country': 'Rwanda',
              'latitude': -1.9506,
              'longitude': 30.0588,
              'delivery_radius': 12.0,
              'minimum_order_amount': 8.0,
              'delivery_fee': 2.0,
              'estimated_delivery_time': 25,
              'rating': 4.2,
              'total_reviews': 85,
              'is_featured': false,
              'is_active': true,
              'is_open': false,
              'created_at': '2024-01-02T00:00:00Z',
              'updated_at': '2024-01-02T00:00:00Z',
              'category_name': 'Fast Food',
              'owner_name': 'Jane Restaurant',
            },
            {
              'id': 3,
              'uuid': 'rest-uuid-3',
              'owner_id': 4,
              'category_id': 3,
              'name': 'Sushi Zen',
              'slug': 'sushi-zen',
              'description': 'Premium Japanese cuisine with fresh sushi and traditional dishes.',
              'logo': 'https://example.com/logos/sushi-zen.jpg',
              'cover_image': 'https://example.com/covers/sushi-zen.jpg',
              'phone': '+250788987654',
              'email': 'hello@sushizen.com',
              'website': 'https://sushizen.com',
              'address_line_1': '789 Asian Avenue',
              'address_line_2': 'Kimihurura',
              'city': 'Kigali',
              'state': 'Kigali Province',
              'postal_code': '00300',
              'country': 'Rwanda',
              'latitude': -1.9355,
              'longitude': 30.0928,
              'delivery_radius': 20.0,
              'minimum_order_amount': 15.0,
              'delivery_fee': 3.0,
              'estimated_delivery_time': 40,
              'rating': 4.8,
              'total_reviews': 200,
              'is_featured': true,
              'is_active': false,
              'is_open': false,
              'created_at': '2024-01-03T00:00:00Z',
              'updated_at': '2024-01-03T00:00:00Z',
              'category_name': 'Asian',
              'owner_name': 'Mike Manager',
            },
            {
              'id': 4,
              'uuid': 'rest-uuid-4',
              'owner_id': 3,
              'category_id': 4,
              'name': 'Mama Mia Italian',
              'slug': 'mama-mia-italian',
              'description': 'Traditional Italian restaurant with pasta, risotto, and wine.',
              'logo': 'https://example.com/logos/mama-mia.jpg',
              'cover_image': 'https://example.com/covers/mama-mia.jpg',
              'phone': '+250788111222',
              'email': 'info@mamamia.com',
              'website': 'https://mamamia.com',
              'address_line_1': '321 Italian Street',
              'address_line_2': 'Nyarutarama',
              'city': 'Kigali',
              'state': 'Kigali Province',
              'postal_code': '00400',
              'country': 'Rwanda',
              'latitude': -1.9282,
              'longitude': 30.1127,
              'delivery_radius': 18.0,
              'minimum_order_amount': 12.0,
              'delivery_fee': 2.8,
              'estimated_delivery_time': 35,
              'rating': 4.6,
              'total_reviews': 150,
              'is_featured': false,
              'is_active': true,
              'is_open': true,
              'created_at': '2024-01-04T00:00:00Z',
              'updated_at': '2024-01-04T00:00:00Z',
              'category_name': 'Italian',
              'owner_name': 'Jane Restaurant',
            },
            {
              'id': 5,
              'uuid': 'rest-uuid-5',
              'owner_id': 4,
              'category_id': 7,
              'name': 'Green Garden Healthy',
              'slug': 'green-garden-healthy',
              'description': 'Fresh, organic, and healthy meals for a balanced lifestyle.',
              'logo': 'https://example.com/logos/green-garden.jpg',
              'cover_image': 'https://example.com/covers/green-garden.jpg',
              'phone': '+250788333444',
              'email': 'hello@greengarden.com',
              'website': 'https://greengarden.com',
              'address_line_1': '654 Health Avenue',
              'address_line_2': 'Remera',
              'city': 'Kigali',
              'state': 'Kigali Province',
              'postal_code': '00500',
              'country': 'Rwanda',
              'latitude': -1.9578,
              'longitude': 30.1086,
              'delivery_radius': 14.0,
              'minimum_order_amount': 9.0,
              'delivery_fee': 2.2,
              'estimated_delivery_time': 28,
              'rating': 4.4,
              'total_reviews': 95,
              'is_featured': false,
              'is_active': true,
              'is_open': true,
              'created_at': '2024-01-05T00:00:00Z',
              'updated_at': '2024-01-05T00:00:00Z',
              'category_name': 'Healthy',
              'owner_name': 'Mike Manager',
            },
          ],
          'pagination': {
            'current_page': 1,
            'total_pages': 1,
            'total_count': 5,
            'per_page': 20,
          }
        };
      default:
        return {'success': false, 'message': 'Endpoint not found'};
    }
  }

  // User Management APIs
  Future<List<User>> getUsers({
    String? search,
    String? role,
    String? status,
    int page = 1,
    int limit = 20,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (role != null && role != 'all') {
      queryParams['role'] = role;
    }
    if (status != null && status != 'all') {
      queryParams['status'] = status;
    }

    // Build endpoint with query parameters
    String endpoint = DatabaseConfig.usersEndpoint;
    if (queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      endpoint = '$endpoint?$queryString';
    }

    final response = await _makeRequest('GET', endpoint, token: token);

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> usersData = response['data'];
      return usersData.map((userData) => User.fromJson(userData)).toList();
    }

    return [];
  }

  Future<User?> getUserById(int id, {String? token}) async {
    final response = await _makeRequest('GET', '${DatabaseConfig.usersEndpoint}/$id', token: token);
    
    if (response['success'] == true && response['data'] != null) {
      return User.fromJson(response['data']);
    }
    
    return null;
  }

  Future<bool> updateUserStatus(int userId, bool isActive, {String? token}) async {
    final response = await _makeRequest(
      'PUT',
      '${DatabaseConfig.usersEndpoint}/$userId/status',
      body: {'is_active': isActive},
      token: token,
    );
    
    return response['success'] == true;
  }

  Future<bool> deleteUser(int userId, {String? token}) async {
    final response = await _makeRequest(
      'DELETE',
      '${DatabaseConfig.usersEndpoint}/$userId',
      token: token,
    );
    
    return response['success'] == true;
  }

  Future<User?> createUser(Map<String, dynamic> userData, {String? token}) async {
    final response = await _makeRequest(
      'POST',
      DatabaseConfig.usersEndpoint,
      body: userData,
      token: token,
    );
    
    if (response['success'] == true && response['data'] != null) {
      return User.fromJson(response['data']);
    }
    
    return null;
  }

  Future<User?> updateUser(int userId, Map<String, dynamic> userData, {String? token}) async {
    final response = await _makeRequest(
      'PUT',
      '${DatabaseConfig.usersEndpoint}/$userId',
      body: userData,
      token: token,
    );
    
    if (response['success'] == true && response['data'] != null) {
      return User.fromJson(response['data']);
    }
    
    return null;
  }

  // Restaurant Management APIs
  Future<List<Restaurant>> getRestaurants({
    String? search,
    String? category,
    String? status,
    int page = 1,
    int limit = 20,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (category != null && category != 'all') {
      queryParams['category'] = category;
    }
    if (status != null && status != 'all') {
      queryParams['status'] = status;
    }

    // Build endpoint with query parameters
    String endpoint = DatabaseConfig.restaurantsEndpoint;
    if (queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      endpoint = '$endpoint?$queryString';
    }

    final response = await _makeRequest('GET', endpoint, token: token);

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> restaurantsData = response['data'];
      return restaurantsData.map((restaurantData) => Restaurant.fromJson(restaurantData)).toList();
    }

    return [];
  }

  Future<Restaurant?> getRestaurantById(int id, {String? token}) async {
    final response = await _makeRequest('GET', '${DatabaseConfig.restaurantsEndpoint}/$id', token: token);

    if (response['success'] == true && response['data'] != null) {
      return Restaurant.fromJson(response['data']);
    }

    return null;
  }

  Future<bool> updateRestaurantStatus(int restaurantId, bool isActive, {String? token}) async {
    final response = await _makeRequest(
      'PUT',
      '${DatabaseConfig.restaurantsEndpoint}/$restaurantId/status',
      body: {'is_active': isActive},
      token: token,
    );

    return response['success'] == true;
  }

  Future<bool> updateRestaurantOpenStatus(int restaurantId, bool isOpen, {String? token}) async {
    final response = await _makeRequest(
      'PUT',
      '${DatabaseConfig.restaurantsEndpoint}/$restaurantId/open-status',
      body: {'is_open': isOpen},
      token: token,
    );

    return response['success'] == true;
  }

  Future<bool> deleteRestaurant(int restaurantId, {String? token}) async {
    final response = await _makeRequest(
      'DELETE',
      '${DatabaseConfig.restaurantsEndpoint}/$restaurantId',
      token: token,
    );

    return response['success'] == true;
  }

  Future<Restaurant?> createRestaurant(Map<String, dynamic> restaurantData, {String? token}) async {
    final response = await _makeRequest(
      'POST',
      DatabaseConfig.restaurantsEndpoint,
      body: restaurantData,
      token: token,
    );

    if (response['success'] == true && response['data'] != null) {
      return Restaurant.fromJson(response['data']);
    }

    return null;
  }

  Future<Restaurant?> updateRestaurant(int restaurantId, Map<String, dynamic> restaurantData, {String? token}) async {
    final response = await _makeRequest(
      'PUT',
      '${DatabaseConfig.restaurantsEndpoint}/$restaurantId',
      body: restaurantData,
      token: token,
    );

    if (response['success'] == true && response['data'] != null) {
      return Restaurant.fromJson(response['data']);
    }

    return null;
  }

  // Restaurant Categories APIs
  Future<List<RestaurantCategory>> getRestaurantCategories({String? token}) async {
    final response = await _makeRequest('GET', '${DatabaseConfig.restaurantsEndpoint}/categories', token: token);

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> categoriesData = response['data'];
      return categoriesData.map((categoryData) => RestaurantCategory.fromJson(categoryData)).toList();
    }

    return [];
  }
}
