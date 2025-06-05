import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/database_config.dart';
import '../models/api_response.dart';

class ApiClient {
  static const Duration _timeout = Duration(seconds: 30);
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _authToken;

  // Set authentication token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // Get authentication headers
  Map<String, String> _getHeaders({Map<String, String>? additionalHeaders}) {
    final headers = Map<String, String>.from(_defaultHeaders);
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }

  // Build full URL
  String _buildUrl(String endpoint) {
    return '${DatabaseConfig.apiBaseUrl}$endpoint';
  }

  // Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T? Function(Map<String, dynamic>)? fromJson,
  ) {
    try {
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      // Check for successful response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.fromJson(responseData, fromJson);
      } else {
        // Handle error responses
        final apiResponse = ApiResponse<T>.fromJson(responseData, null);
        throw ApiException(
          apiResponse.message,
          statusCode: response.statusCode,
          errors: apiResponse.errors,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      
      // Handle JSON parsing errors or other exceptions
      throw ApiException(
        'Failed to parse response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }

  // Handle network errors
  Future<T> _handleNetworkErrors<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HttpException {
      throw NetworkException('HTTP error occurred');
    } on FormatException {
      throw NetworkException('Invalid response format');
    } catch (e) {
      if (e is ApiException || e is NetworkException) {
        rethrow;
      }
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  // GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    T? Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _handleNetworkErrors(() async {
      Uri uri = Uri.parse(_buildUrl(endpoint));
      
      if (queryParameters != null) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(_timeout);

      return _handleResponse<T>(response, fromJson);
    });
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T? Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _handleNetworkErrors(() async {
      final uri = Uri.parse(_buildUrl(endpoint));
      
      final response = await http
          .post(
            uri,
            headers: _getHeaders(),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse<T>(response, fromJson);
    });
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T? Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _handleNetworkErrors(() async {
      final uri = Uri.parse(_buildUrl(endpoint));
      
      final response = await http
          .put(
            uri,
            headers: _getHeaders(),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse<T>(response, fromJson);
    });
  }

  // DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T? Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _handleNetworkErrors(() async {
      final uri = Uri.parse(_buildUrl(endpoint));
      
      final response = await http
          .delete(uri, headers: _getHeaders())
          .timeout(_timeout);

      return _handleResponse<T>(response, fromJson);
    });
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      final response = await get('/test/database');
      return response.success;
    } catch (e) {
      return false;
    }
  }

  // Upload file (for future use)
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    String filePath,
    String fieldName, {
    Map<String, String>? additionalFields,
    T? Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _handleNetworkErrors(() async {
      final uri = Uri.parse(_buildUrl(endpoint));
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      request.headers.addAll(_getHeaders());
      
      // Add file
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      
      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }
      
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse<T>(response, fromJson);
    });
  }

  // Clear authentication
  void clearAuth() {
    _authToken = null;
  }

  // Get current auth token
  String? get authToken => _authToken;

  // Check if authenticated
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;
}
