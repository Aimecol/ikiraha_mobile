# Restaurant Manager Screens - Implementation Guide

## Overview
This document outlines the complete implementation of Restaurant Manager screens for the Ikiraha mobile ordering system. Restaurant managers have operational control over menu items, orders, and day-to-day restaurant operations but limited access compared to restaurant owners.

## Role Permissions (Based on Database Schema)
According to the database schema, restaurant managers have the following permissions:
```json
{
  "own_restaurant": ["read"], 
  "own_products": ["read", "update"], 
  "own_orders": ["read", "update"]
}
```

**Key Differences from Restaurant Owner:**
- ❌ Cannot modify core restaurant settings (name, address, contact info)
- ❌ Cannot access financial/analytics data
- ❌ Cannot manage staff or other managers
- ✅ Can manage menu items and inventory
- ✅ Can process and update orders
- ✅ Can view restaurant information (read-only)

## Implemented Screens

### 1. Restaurant Manager Dashboard (`RestaurantManagerDashboard`)
**Main navigation hub with 4 tabs:**
- Dashboard (Home)
- Menu Management
- Order Management  
- Profile

**Features:**
- Role-based access control
- Professional amber-themed UI (distinct from owner's orange theme)
- Profile dropdown with user info
- Automatic logout on role change
- Notification support

### 2. Manager Home Screen (`ManagerHomeScreen`)
**Dashboard overview with:**

#### Welcome Card
- Personalized greeting with manager name
- Restaurant name and status
- Restaurant rating and review count
- Open/closed status indicator

#### Restaurant Information (Read-Only)
- Restaurant name, category, address
- Contact information
- Current status and ratings
- Manager assignment date

#### Today's Statistics
- Orders today count
- Pending orders
- Today's revenue
- Average order value

#### Quick Actions
- View Orders
- Add Menu Item
- Update Stock
- View Reports

#### Recent Activity Feed
- New orders received
- Menu updates
- Order completions
- Stock alerts
- Customer reviews

### 3. Menu Management Screen (`MenuManagementScreen`)
**Complete menu item management:**

#### Search & Filtering
- Search by item name/description
- Filter by category (Pizza, Salads, Appetizers, etc.)
- Filter by status (Available, Unavailable, Low Stock)

#### Menu Statistics
- Total items count
- Available items
- Low stock alerts
- Filtered results count

#### Menu Items List
- Item details with pricing
- Category and preparation time
- Vegetarian indicators
- Stock levels with low stock warnings
- Availability status

#### Item Actions
- View detailed item information
- Edit item details (price, description, etc.)
- Enable/disable item availability
- Update stock levels
- Duplicate items for variants

#### Features
- Color-coded status indicators
- Expandable item cards
- Stock management alerts
- Category-based organization

### 4. Order Management Screen (`OrderManagementScreen`)
**Real-time order processing:**

#### Search & Filtering
- Search by order number, customer name, or phone
- Filter by order status (Pending, Preparing, Ready, etc.)
- Filter by order type (Delivery, Pickup, Dine-in)

#### Order Statistics
- Total orders
- Pending orders requiring attention
- Orders currently being prepared
- Orders ready for pickup/delivery

#### Order Processing Workflow
**Status-based actions:**
- **Pending**: Accept or Reject orders
- **Confirmed**: Start preparing
- **Preparing**: Mark as ready
- **Ready**: Mark as picked up or out for delivery

#### Order Details
- Expandable order cards
- Complete item list
- Special instructions
- Customer contact information
- Order timing and estimates

#### Customer Communication
- Direct call functionality
- Order status updates
- Delivery coordination

### 5. Manager Profile Screen (`ManagerProfileScreen`)
**Personal and restaurant information:**

#### Profile Header
- Manager avatar with role color coding
- Name and email display
- Role badge (Restaurant Manager)

#### Restaurant Information (Read-Only)
- Restaurant details
- Performance metrics
- Manager assignment information

#### Performance Overview
- Orders processed today
- Menu items managed
- Average ratings
- Monthly statistics

#### Profile Options
- Edit personal profile
- Change password
- Notification settings
- Performance reports
- Help & support
- About information

## Technical Implementation

### File Structure
```
lib/screens/restaurant_manager/
├── restaurant_manager_dashboard.dart    # Main dashboard
├── manager_home_screen.dart            # Dashboard home
├── menu_management_screen.dart         # Menu operations
├── order_management_screen.dart        # Order processing
└── manager_profile_screen.dart         # Profile & settings
```

### Key Features

#### Role-Based Security
- Automatic role validation on screen access
- Redirect to login if role changes
- Limited permissions enforcement

#### UI/UX Design
- Amber color theme for manager role
- Material Design 3 components
- Responsive layouts
- Professional interface design

#### Data Models
- `MenuItem` model with stock management
- `Order` model with status workflow
- Mock data for demonstration

#### State Management
- Loading states for all operations
- Error handling and user feedback
- Real-time data updates (simulated)

### Integration Points

#### Updated Services
- `RoleBasedNavigation`: Added restaurant manager support
- `AuthService`: Enhanced with `isRestaurantManager` check
- Role-specific navigation items

#### Navigation Flow
- Automatic redirection after login based on role
- Role-specific bottom navigation
- Secure logout functionality

## Key Differences from Restaurant Owner

| Feature | Restaurant Owner | Restaurant Manager |
|---------|------------------|-------------------|
| Restaurant Settings | ✅ Full Access | ❌ Read Only |
| Menu Management | ✅ Full CRUD | ✅ Read/Update |
| Order Management | ✅ Full Access | ✅ Process Orders |
| Financial Data | ✅ Full Analytics | ❌ Limited View |
| Staff Management | ✅ Manage Staff | ❌ No Access |
| System Settings | ✅ Configure | ❌ No Access |
| Navigation Tabs | 4 tabs + Analytics | 4 tabs (Profile instead) |

## Testing the Implementation

### Method 1: Database Setup
Create a restaurant manager user:
```sql
INSERT INTO users (
    uuid, role_id, email, password_hash, 
    first_name, last_name, is_active, is_verified
) VALUES (
    UUID(), 4, -- restaurant_manager role_id
    'manager@pizzapalace.com',
    '$2y$10$hashed_password',
    'John', 'Manager', 1, 1
);
```

### Method 2: Role Test Screen
1. Use the existing Role Test Screen
2. Select "Restaurant Manager" role
3. View navigation and permissions

## Future Enhancements

### Backend Integration
- Connect to actual restaurant APIs
- Real-time order notifications
- Inventory management system
- Performance analytics

### Advanced Features
- Shift management
- Staff scheduling
- Inventory alerts
- Customer feedback management
- Sales reporting
- Multi-location support

### Mobile Optimizations
- Offline order processing
- Push notifications
- Barcode scanning for inventory
- Voice commands for order updates

## Conclusion

The Restaurant Manager screens provide a comprehensive operational interface tailored to the specific needs and permissions of restaurant managers. The implementation follows the database schema permissions, ensuring managers have the tools they need for daily operations while maintaining appropriate access controls.

The interface is designed to be efficient for high-volume order processing while providing clear visibility into menu management and restaurant performance. The role-based design ensures a secure and appropriate user experience for restaurant management staff.
