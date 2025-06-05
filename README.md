# 🍽️ Ikiraha Mobile - Food Ordering System

A comprehensive Flutter mobile application for food ordering with multi-user capabilities, customer behavior analysis, recommendation system, admin functionalities, and multi-language support.

## 🎯 Features

### ✅ **Completed Setup**

- **Database**: Complete normalized MySQL database with 52+ tables
- **Flutter Project**: Initialized with essential dependencies
- **Multi-language Support**: Ready for 5 languages (English, French, Spanish, Kinyarwanda, Swahili)
- **State Management**: Provider pattern implemented
- **Navigation**: Bottom navigation with 4 main screens
- **Theme**: Material 3 design with light/dark theme support

### 🚀 **Core Features (Database Ready)**

- **Multi-User System**: Super Admin, Admin, Restaurant Owner, Manager, Driver, Customer roles
- **Restaurant Management**: Categories, cuisines, operating hours, translations
- **Product Management**: Menu items, variants, add-ons, inventory tracking
- **Order System**: Complete order lifecycle with status tracking
- **Payment Integration**: Ready for multiple payment methods
- **Delivery Management**: Driver tracking and assignment
- **Customer Analytics**: User behavior tracking and preferences
- **Recommendation Engine**: Collaborative and content-based filtering
- **Reviews & Ratings**: Restaurant and product review system
- **Loyalty Program**: Points-based rewards system
- **Notifications**: Push, email, SMS notification templates
- **Admin Dashboard**: Analytics, reporting, and management tools

## 📊 Database Schema

The database includes **52 tables** organized into:

### Core System

- `languages` - Multi-language support
- `user_roles` - Role-based access control
- `users` - User management
- `user_addresses` - Delivery addresses
- `user_payment_methods` - Payment methods

### Restaurant Management

- `restaurants` - Restaurant information
- `restaurant_categories` - Restaurant categorization
- `restaurant_hours` - Operating hours
- `cuisines` - Cuisine types
- `restaurant_translations` - Multi-language content

### Product Management

- `products` - Menu items
- `product_categories` - Product categorization
- `product_variants` - Size, color variations
- `product_addons` - Extra items
- `product_inventory` - Stock management

### Order System

- `orders` - Order information
- `order_items` - Order line items
- `order_statuses` - Order status tracking
- `payment_transactions` - Payment processing

### Analytics & Recommendations

- `user_activities` - Behavior tracking
- `user_preferences` - User preferences
- `product_recommendations` - AI recommendations
- `user_similarities` - Collaborative filtering

### Additional Features

- `coupons` - Discount management
- `loyalty_programs` - Rewards system
- `delivery_drivers` - Driver management
- `notifications` - Notification system

## 🛠️ Setup Instructions

### Prerequisites

- Flutter SDK (3.32.0+)
- XAMPP with MySQL
- Android Studio / VS Code
- Git

### Database Setup

1. **Start XAMPP** and ensure MySQL is running
2. **Import Database**:

   ```bash
   # Navigate to project directory
   cd /c/xampp/htdocs/clone/ikiraha_mobile

   # Import the database schema
   /c/xampp/mysql/bin/mysql.exe -u root < database_schema.sql
   ```

3. **Verify Database**: Open phpMyAdmin at `http://localhost/phpmyadmin`
   - Database: `ikiraha_ordering_system`
   - Tables: 52 tables should be visible

### Flutter Setup

1. **Install Dependencies**:

   ```bash
   flutter pub get
   ```

2. **Run the App**:
   ```bash
   flutter run
   ```

## 📱 Current App Structure

```
lib/
├── main.dart                 # App entry point
├── config/
│   └── database_config.dart  # Database configuration
└── screens/                  # UI screens (to be expanded)
```

## 🔧 Configuration

### Database Connection

Edit `lib/config/database_config.dart`:

```dart
static const String host = 'localhost';
static const String database = 'ikiraha_ordering_system';
static const String username = 'root';
static const String password = ''; // XAMPP default
```

### API Configuration

```dart
static const String apiBaseUrl = 'http://localhost/ikiraha_api';
```

## 🌐 Multi-Language Support

Supported languages:

- 🇺🇸 English (en)
- 🇫🇷 French (fr)
- 🇪🇸 Spanish (es)
- 🇷🇼 Kinyarwanda (rw)
- 🇹🇿 Swahili (sw)

## 📦 Dependencies

### Core Dependencies

- `flutter` - UI framework
- `provider` - State management
- `http` - HTTP requests
- `sqflite` - Local database
- `shared_preferences` - Local storage
- `intl` - Internationalization

### UI Dependencies

- `cupertino_icons` - iOS-style icons
- `shimmer` - Loading animations
- `fl_chart` - Charts and analytics
- `flutter_rating_bar` - Rating components
- `table_calendar` - Calendar widget

### Utilities

- `uuid` - Unique ID generation
- `timeago` - Time formatting
- `url_launcher` - External links
- `connectivity_plus` - Network status

## 🚧 Next Steps

1. **Backend API Development**

   - Create REST API endpoints
   - Implement authentication
   - Connect to MySQL database

2. **UI Development**

   - Restaurant listing screen
   - Product catalog
   - Shopping cart
   - Order tracking
   - User profile

3. **Advanced Features**
   - Real-time notifications
   - GPS tracking
   - Payment integration
   - Analytics dashboard

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 📞 Support

For support and questions:

- Email: support@ikiraha.com
- Phone: +250788123456

---

**Status**: ✅ Database Created | ✅ Flutter Project Initialized | 🚧 Development Ready
