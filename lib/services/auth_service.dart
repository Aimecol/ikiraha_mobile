import 'package:shared_preferences/shared_preferences.dart';
import '../config/database_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _isLoggedInKey = 'is_logged_in';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Current user data
  String? _currentUserId;
  String? _currentUserEmail;
  String? _currentUserName;
  String? _authToken;
  bool _isLoggedIn = false;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserId => _currentUserId;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;
  String? get authToken => _authToken;

  // Initialize auth service (call this on app startup)
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    _currentUserId = prefs.getString(_userIdKey);
    _currentUserEmail = prefs.getString(_userEmailKey);
    _currentUserName = prefs.getString(_userNameKey);
    _authToken = prefs.getString(_tokenKey);
  }

  // Login method
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      // TODO: Implement actual API call to your backend
      // For now, we'll simulate a successful login
      
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user data (replace with actual API response)
      final userData = {
        'id': '1',
        'email': email,
        'name': 'John Doe',
        'token': 'mock_auth_token_${DateTime.now().millisecondsSinceEpoch}',
      };

      // Save user data
      await _saveUserData(
        userId: userData['id']!,
        email: userData['email']!,
        name: userData['name']!,
        token: userData['token']!,
        rememberMe: rememberMe,
      );

      return true;
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
  }) async {
    try {
      // TODO: Implement actual API call to your backend
      // For now, we'll simulate a successful registration
      
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user data (replace with actual API response)
      final userData = {
        'id': '1',
        'email': email,
        'name': '$firstName $lastName',
        'token': 'mock_auth_token_${DateTime.now().millisecondsSinceEpoch}',
      };

      // Save user data
      await _saveUserData(
        userId: userData['id']!,
        email: userData['email']!,
        name: userData['name']!,
        token: userData['token']!,
        rememberMe: true,
      );

      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Clear all stored data
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.setBool(_isLoggedInKey, false);
    
    // Clear in-memory data
    _currentUserId = null;
    _currentUserEmail = null;
    _currentUserName = null;
    _authToken = null;
    _isLoggedIn = false;
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData({
    required String userId,
    required String email,
    required String name,
    required String token,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save to SharedPreferences
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_isLoggedInKey, true);
    
    // Update in-memory data
    _currentUserId = userId;
    _currentUserEmail = email;
    _currentUserName = name;
    _authToken = token;
    _isLoggedIn = true;
  }

  // Check if token is valid (you can implement token expiry logic here)
  Future<bool> isTokenValid() async {
    if (_authToken == null) return false;
    
    // TODO: Implement actual token validation with your backend
    // For now, we'll just check if token exists
    return _authToken!.isNotEmpty;
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      if (_authToken == null) return false;
      
      // TODO: Implement actual token refresh with your backend
      // For now, we'll just generate a new mock token
      final newToken = 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}';
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, newToken);
      _authToken = newToken;
      
      return true;
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

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      // TODO: Implement actual API call to update profile
      
      if (name != null) {
        _currentUserName = name;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userNameKey, name);
      }
      
      if (email != null) {
        _currentUserEmail = email;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userEmailKey, email);
      }
      
      return true;
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
      // TODO: Implement actual API call to change password
      
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      
      return true;
    } catch (e) {
      print('Password change error: $e');
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      // TODO: Implement actual API call to delete account
      
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Logout after successful deletion
      await logout();
      
      return true;
    } catch (e) {
      print('Account deletion error: $e');
      return false;
    }
  }
}
