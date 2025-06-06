import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../screens/home/home_page.dart';
import '../screens/super_admin/super_admin_dashboard.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/restaurant_owner/restaurant_owner_dashboard.dart';
import '../screens/restaurant_manager/restaurant_manager_dashboard.dart';
import '../screens/delivery_driver/driver_dashboard.dart';
import '../screens/auth/login_screen.dart';

class RoleBasedNavigation {
  static final AuthService _authService = AuthService();

  /// Get the appropriate home screen based on user role
  static Widget getHomeScreenForRole() {
    if (!_authService.isLoggedIn || _authService.currentUser == null) {
      return const LoginScreen();
    }

    switch (_authService.currentUserRole) {
      case 'super_admin':
        return const SuperAdminDashboard();
      case 'admin':
        return const AdminDashboard();
      case 'restaurant_owner':
        return const RestaurantOwnerDashboard();
      case 'restaurant_manager':
        return const RestaurantManagerDashboard();
      case 'delivery_driver':
        return const DriverDashboard();
      case 'customer':
      default:
        return const HomePage();
    }
  }

  /// Navigate to role-specific home screen
  static void navigateToRoleBasedHome(BuildContext context) {
    final homeScreen = getHomeScreenForRole();
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => homeScreen),
      (route) => false,
    );
  }

  /// Check if user can access a specific screen
  static bool canAccessScreen(String screenName) {
    if (!_authService.isLoggedIn) return false;

    switch (screenName) {
      case 'super_admin':
        return _authService.isSuperAdmin;
      case 'admin':
        return _authService.isAdmin;
      case 'restaurant_management':
        return _authService.isRestaurantOwner || _authService.isRestaurantManager || _authService.isAdmin;
      case 'delivery_management':
        return _authService.isDeliveryDriver || _authService.isAdmin;
      case 'user_management':
        return _authService.isAdmin;
      case 'system_settings':
        return _authService.isSuperAdmin;
      case 'analytics':
        return _authService.isAdmin;
      default:
        return true; // Allow access to general screens
    }
  }

  /// Get navigation items based on user role
  static List<BottomNavigationBarItem> getNavigationItems() {
    if (_authService.isSuperAdmin) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant),
          label: 'Restaurants',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];
    } else if (_authService.isAdmin) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant),
          label: 'Restaurants',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Reports',
        ),
      ];
    } else if (_authService.isRestaurantOwner) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
      ];
    } else if (_authService.isRestaurantManager) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else if (_authService.isDeliveryDriver) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.delivery_dining),
          label: 'Deliveries',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      // Customer navigation
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant),
          label: 'Restaurants',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
  }

  /// Get role display name
  static String getRoleDisplayName(String? role) {
    switch (role) {
      case 'super_admin':
        return 'Super Administrator';
      case 'admin':
        return 'Administrator';
      case 'restaurant_owner':
        return 'Restaurant Owner';
      case 'restaurant_manager':
        return 'Restaurant Manager';
      case 'delivery_driver':
        return 'Delivery Driver';
      case 'customer':
        return 'Customer';
      default:
        return 'User';
    }
  }

  /// Get role color
  static Color getRoleColor(String? role) {
    switch (role) {
      case 'super_admin':
        return Colors.purple;
      case 'admin':
        return Colors.red;
      case 'restaurant_owner':
        return Colors.orange;
      case 'restaurant_manager':
        return Colors.amber;
      case 'delivery_driver':
        return Colors.blue;
      case 'customer':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
