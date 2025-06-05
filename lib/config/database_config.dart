// Database Configuration for Ikiraha Mobile Ordering System
// This file contains database connection settings for XAMPP MySQL

class DatabaseConfig {
  // XAMPP MySQL Database Configuration
  static const String host = 'localhost';
  static const String database = 'ikiraha_ordering_system';
  static const String username = 'root';
  static const String password = ''; // Default XAMPP password is empty
  static const int port = 3306;
  
  // API Base URL (backend integration)
  static const String apiBaseUrl = 'http://localhost/clone/ikiraha_mobile/backend/api';
  
  // App Configuration
  static const String appName = 'Ikiraha Mobile';
  static const String appVersion = '1.0.0';
  
  // Default Settings
  static const String defaultLanguage = 'en';
  static const String defaultCurrency = 'USD';
  static const double defaultDeliveryRadius = 25.0; // km
  static const int defaultDeliveryTime = 30; // minutes
  
  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String restaurantsEndpoint = '/restaurants';
  static const String productsEndpoint = '/products';
  static const String ordersEndpoint = '/orders';
  static const String usersEndpoint = '/users';
  static const String analyticsEndpoint = '/analytics';
  
  // Local Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String languageKey = 'selected_language';
  static const String themeKey = 'selected_theme';
  static const String locationKey = 'user_location';
  
  // Database Connection String (for reference)
  static String get connectionString => 
      'mysql://$username:$password@$host:$port/$database';
  
  // Full API URL builder
  static String getApiUrl(String endpoint) => '$apiBaseUrl$endpoint';
}

// Environment Configuration
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment currentEnvironment = Environment.development;
  
  static bool get isDevelopment => currentEnvironment == Environment.development;
  static bool get isStaging => currentEnvironment == Environment.staging;
  static bool get isProduction => currentEnvironment == Environment.production;
  
  // Debug settings
  static bool get enableLogging => isDevelopment || isStaging;
  static bool get enableDebugMode => isDevelopment;
}

// Feature Flags
class FeatureFlags {
  static const bool enableAnalytics = true;
  static const bool enableRecommendations = true;
  static const bool enableMultiLanguage = true;
  static const bool enablePushNotifications = true;
  static const bool enableLocationServices = true;
  static const bool enablePaymentGateway = false; // Will be enabled later
  static const bool enableSocialLogin = false; // Will be enabled later
}
