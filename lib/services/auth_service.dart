import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import 'api_client.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _tokenExpiryKey = 'token_expiry';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // API client
  final ApiClient _apiClient = ApiClient();

  // Current user data
  User? _currentUser;
  String? _authToken;
  bool _isLoggedIn = false;
  DateTime? _tokenExpiry;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  String? get currentUserId => _currentUser?.id.toString();
  String? get currentUserEmail => _currentUser?.email;
  String? get currentUserName => _currentUser?.fullName;
  String? get authToken => _authToken;

  // Initialize auth service (call this on app startup)
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    _authToken = prefs.getString(_tokenKey);

    // Load user data
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      try {
        // Parse the JSON string properly
        final userData = Map<String, dynamic>.from(
          jsonDecode(userDataString)
        );
        _currentUser = User.fromJson(userData);
      } catch (e) {
        // Clear invalid user data
        await _clearStoredData();
      }
    }

    // Load token expiry
    final expiryString = prefs.getString(_tokenExpiryKey);
    if (expiryString != null) {
      _tokenExpiry = DateTime.tryParse(expiryString);
    }

    // Set token in API client
    if (_authToken != null) {
      _apiClient.setAuthToken(_authToken);
    }

    // Check if token is expired
    if (_tokenExpiry != null && DateTime.now().isAfter(_tokenExpiry!)) {
      await logout();
    }
  }

  // Login method
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final loginRequest = LoginRequest(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      final response = await _apiClient.post<AuthData>(
        '/login.php',
        body: loginRequest.toJson(),
        fromJson: (json) => AuthData.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _saveAuthData(response.data!);
        return true;
      } else {
        throw ApiException(response.message);
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Register method
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      final registerRequest = RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      final response = await _apiClient.post<AuthData>(
        '/register.php',
        body: registerRequest.toJson(),
        fromJson: (json) => AuthData.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _saveAuthData(response.data!);
        return true;
      } else {
        throw ApiException(response.message);
      }
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    await _clearStoredData();

    // Clear API client token
    _apiClient.clearAuth();
  }

  // Clear stored data
  Future<void> _clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear all stored data
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_tokenExpiryKey);
    await prefs.setBool(_isLoggedInKey, false);

    // Clear in-memory data
    _currentUser = null;
    _authToken = null;
    _tokenExpiry = null;
    _isLoggedIn = false;
  }

  // Save authentication data
  Future<void> _saveAuthData(AuthData authData) async {
    final prefs = await SharedPreferences.getInstance();

    // Calculate token expiry
    final expiry = DateTime.now().add(Duration(seconds: authData.expiresIn));

    // Save to SharedPreferences
    await prefs.setString(_tokenKey, authData.token);
    await prefs.setString(_userDataKey, jsonEncode(authData.user.toJson()));
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
    await prefs.setBool(_isLoggedInKey, true);

    // Update in-memory data
    _currentUser = authData.user;
    _authToken = authData.token;
    _tokenExpiry = expiry;
    _isLoggedIn = true;

    // Set token in API client
    _apiClient.setAuthToken(authData.token);
  }

  // Check if token is valid
  Future<bool> isTokenValid() async {
    if (_authToken == null || _authToken!.isEmpty) return false;

    // Check if token is expired
    if (_tokenExpiry != null && DateTime.now().isAfter(_tokenExpiry!)) {
      return false;
    }

    try {
      // Validate token with backend
      final response = await _apiClient.post<User>(
        '/auth/validate',
        body: {'token': _authToken},
        fromJson: (json) => User.fromJson(json['user']),
      );

      return response.success;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      if (_authToken == null) return false;

      final response = await _apiClient.post<AuthData>(
        '/auth/refresh',
        body: {'token': _authToken},
        fromJson: (json) => AuthData.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _saveAuthData(response.data!);
        return true;
      }

      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  // Get authorization headers for API calls
  Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  // Get user profile
  Future<User?> getUserProfile() async {
    try {
      final response = await _apiClient.get<User>(
        '/auth/profile',
        fromJson: (json) => User.fromJson(json['user']),
      );

      if (response.success && response.data != null) {
        _currentUser = response.data;
        return response.data;
      }

      return null;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      final updateRequest = UpdateProfileRequest(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      final response = await _apiClient.put<User>(
        '/auth/profile',
        body: updateRequest.toJson(),
        fromJson: (json) => User.fromJson(json['user']),
      );

      if (response.success && response.data != null) {
        _currentUser = response.data;

        // Update stored user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userDataKey, jsonEncode(_currentUser!.toJson()));

        return true;
      }

      return false;
    } catch (e) {
      print('Profile update error: $e');
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final changePasswordRequest = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      final response = await _apiClient.post(
        '/auth/change-password',
        body: changePasswordRequest.toJson(),
      );

      return response.success;
    } catch (e) {
      print('Password change error: $e');
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      final response = await _apiClient.delete('/auth/profile');

      if (response.success) {
        // Logout after successful deletion
        await logout();
        return true;
      }

      return false;
    } catch (e) {
      print('Account deletion error: $e');
      return false;
    }
  }

  // Test backend connection
  Future<bool> testConnection() async {
    try {
      final response = await _apiClient.get('/test_connection.php');
      return response.success;
    } catch (e) {
      print('Connection test error: $e');
      return false;
    }
  }

  // Get error message from exception
  String getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error is NetworkException) {
      return error.message;
    } else if (error is AuthenticationException) {
      return error.message;
    } else {
      return 'An unexpected error occurred';
    }
  }
}
