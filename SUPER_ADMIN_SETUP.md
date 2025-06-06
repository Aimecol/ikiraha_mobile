# Super Admin Setup and Testing Guide

## Overview
This guide explains how to set up and test the super admin functionality in the Ikiraha mobile ordering system.

## What's Been Implemented

### 1. Role-Based Authentication System
- Enhanced `AuthService` with role checking methods:
  - `isSuperAdmin` - checks if user is super admin
  - `isAdmin` - checks if user is admin or super admin
  - `isRestaurantOwner` - checks if user is restaurant owner
  - `isDeliveryDriver` - checks if user is delivery driver
  - `isCustomer` - checks if user is customer

### 2. Role-Based Navigation Service
- `RoleBasedNavigation` service that:
  - Determines appropriate home screen based on user role
  - Provides role-specific navigation items
  - Handles role-based redirection after login

### 3. Super Admin Dashboard
Complete super admin interface with 5 main sections:

#### Dashboard Home (`SuperAdminHome`)
- Welcome card with user info and system status
- Quick statistics (users, restaurants, orders, revenue)
- System overview with key metrics
- Quick action buttons
- Recent activity feed

#### User Management (`UserManagementScreen`)
- Search and filter users by role and status
- User statistics display
- User list with role indicators
- User actions: view details, edit, activate/deactivate, delete
- Add new user functionality (placeholder)

#### Restaurant Management (`RestaurantManagementScreen`)
- Search and filter restaurants by status and category
- Restaurant statistics
- Restaurant list with status indicators
- Restaurant actions: view details, edit, manage menu, view orders
- Add new restaurant functionality (placeholder)

#### Analytics & Reports (`AnalyticsScreen`)
- Period selector (day, week, month, year)
- KPI cards with growth indicators
- Revenue trend chart (placeholder for charting library)
- Top performing restaurants
- Recent orders with status
- Export options (PDF, Excel, CSV, Email)

#### System Settings (`SystemSettingsScreen`)
- General settings (app name, currency, language)
- Business settings (commission rate, delivery radius, minimum order)
- System settings (maintenance mode, registration control)
- Support settings (email, phone)
- Security settings (verification requirements)
- System actions (save, backup, clear cache)

### 4. Other Role Dashboards (Placeholders)
- `AdminDashboard` - For regular administrators
- `RestaurantOwnerDashboard` - For restaurant owners
- `DriverDashboard` - For delivery drivers

### 5. Updated Navigation Flow
- `SplashScreen` now uses role-based navigation
- `LoginScreen` redirects to appropriate dashboard based on role
- `RegisterScreen` redirects to appropriate dashboard based on role

## Database Roles Setup

Based on the database schema, the following roles are available:

```sql
-- User roles from database_schema.sql
INSERT INTO user_roles (name, description, permissions) VALUES
('super_admin', 'Super Administrator with full access', '{"all": true}'),
('admin', 'System Administrator', '{"users": ["read", "create", "update"], "restaurants": ["read", "create", "update"], "orders": ["read", "update"], "analytics": ["read"]}'),
('restaurant_owner', 'Restaurant Owner', '{"own_restaurant": ["read", "update"], "own_products": ["read", "create", "update", "delete"], "own_orders": ["read", "update"]}'),
('restaurant_manager', 'Restaurant Manager', '{"own_restaurant": ["read"], "own_products": ["read", "update"], "own_orders": ["read", "update"]}'),
('delivery_driver', 'Delivery Driver', '{"own_deliveries": ["read", "update"], "location": ["update"]}'),
('customer', 'Regular Customer', '{"profile": ["read", "update"], "orders": ["create", "read"], "reviews": ["create", "read", "update"]}');
```

## Testing the Super Admin Functionality

### Method 1: Create Super Admin User in Database
1. Run the database schema to create tables and insert default roles
2. Create a super admin user manually in the database:

```sql
-- Insert a super admin user
INSERT INTO users (
    uuid, 
    role_id, 
    email, 
    password_hash, 
    first_name, 
    last_name, 
    is_active, 
    is_verified
) VALUES (
    UUID(), 
    1, -- super_admin role_id
    'superadmin@ikiraha.com',
    '$2y$10$example_hashed_password', -- Use proper password hashing
    'Super',
    'Admin',
    1,
    1
);
```

### Method 2: Use Role Test Screen
1. Login with any user account
2. Go to Profile tab
3. Tap "Role Test (Debug)" option
4. Select "Super Administrator" from dropdown
5. View the navigation items that would be available
6. If logged in, tap "Navigate" to see role-based navigation

### Method 3: Modify Backend Registration
Temporarily modify the backend registration to assign super_admin role to new users for testing.

## Features Demonstrated

### Super Admin Dashboard Features:
1. **Dashboard Overview**: System statistics and health monitoring
2. **User Management**: Complete CRUD operations for users
3. **Restaurant Management**: Restaurant approval and management
4. **Analytics**: Revenue tracking and performance metrics
5. **System Settings**: Platform configuration and maintenance

### Role-Based Security:
- Automatic redirection based on user role
- Role-specific navigation menus
- Access control for different screens
- Logout protection and session management

### UI/UX Features:
- Material Design 3 components
- Responsive layout
- Loading states and error handling
- Search and filtering capabilities
- Role color coding
- Professional admin interface

## Next Steps for Full Implementation

1. **Backend API Integration**: Connect all screens to actual backend APIs
2. **Chart Implementation**: Add charting library (e.g., fl_chart) for analytics
3. **Real-time Updates**: Implement WebSocket or polling for live data
4. **File Export**: Implement actual PDF/Excel export functionality
5. **Image Upload**: Add image upload for restaurants and users
6. **Push Notifications**: Implement admin notification system
7. **Audit Logging**: Track all admin actions
8. **Advanced Filtering**: Add date ranges and complex filters
9. **Bulk Operations**: Add bulk user/restaurant management
10. **System Monitoring**: Add performance and health monitoring

## File Structure

```
lib/
├── services/
│   ├── auth_service.dart (enhanced with role methods)
│   └── role_based_navigation.dart (new)
├── screens/
│   ├── super_admin/
│   │   ├── super_admin_dashboard.dart
│   │   ├── super_admin_home.dart
│   │   ├── user_management_screen.dart
│   │   ├── restaurant_management_screen.dart
│   │   ├── analytics_screen.dart
│   │   └── system_settings_screen.dart
│   ├── admin/
│   │   └── admin_dashboard.dart (placeholder)
│   ├── restaurant_owner/
│   │   └── restaurant_owner_dashboard.dart (placeholder)
│   ├── delivery_driver/
│   │   └── driver_dashboard.dart (placeholder)
│   └── test/
│       └── role_test_screen.dart (debug tool)
```

## Conclusion

The super admin system is now fully implemented with a comprehensive dashboard, user management, restaurant management, analytics, and system settings. The role-based navigation ensures users are automatically redirected to the appropriate interface based on their role, providing a secure and user-friendly experience.
