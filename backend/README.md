# 🚀 Ikiraha Mobile Backend API

Comprehensive PHP backend API for the Ikiraha Mobile food ordering system with authentication, user management, and database integration.

## 📋 Table of Contents

- [Features](#features)
- [Installation](#installation)
- [API Endpoints](#api-endpoints)
- [Authentication](#authentication)
- [Database Schema](#database-schema)
- [Error Handling](#error-handling)
- [Testing](#testing)

## ✨ Features

- **JWT Authentication** - Secure token-based authentication
- **User Registration & Login** - Complete user management system
- **Password Security** - Bcrypt password hashing
- **Input Validation** - Comprehensive data validation
- **CORS Support** - Cross-origin resource sharing enabled
- **Error Handling** - Structured error responses
- **Rate Limiting** - Basic rate limiting implementation
- **Database Integration** - MySQL with PDO
- **Middleware Support** - Authentication middleware
- **API Documentation** - Complete endpoint documentation

## 🛠️ Installation

### Prerequisites

- PHP 7.4 or higher
- MySQL 5.7 or higher
- XAMPP (recommended for development)
- Composer (optional, for dependencies)

### Setup Steps

1. **Copy Backend Files**

   ```bash
   # Copy the backend folder to your XAMPP htdocs directory
   cp -r backend /c/xampp/htdocs/ikiraha_mobile/
   ```

2. **Database Configuration**

   - Ensure your MySQL database `ikiraha_ordering_system` is running
   - Update database credentials in `config/database.php` if needed

3. **Set Permissions**

   ```bash
   # Make sure PHP can write to log directories
   chmod 755 backend/
   chmod 644 backend/api/**/*.php
   ```

4. **Test Installation**
   ```bash
   # Test database connection
   curl http://localhost/ikiraha_mobile/backend/api/test/database
   ```

## 🔗 API Endpoints

### Base URL

```
http://localhost/ikiraha_mobile/backend/api
```

### Authentication Endpoints

#### 1. User Registration

```http
POST /auth/register
Content-Type: application/json

{
  "first_name": "John",
  "last_name": "Doe",
  "email": "john.doe@example.com",
  "phone": "+250788123456",
  "password": "SecurePass123",
  "date_of_birth": "1990-01-01",
  "gender": "male"
}
```

**Response:**

```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "uuid": "123e4567-e89b-12d3-a456-426614174000",
      "email": "john.doe@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "role_name": "customer"
    },
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "expires_in": 86400
  }
}
```

#### 2. User Login

```http
POST /auth/login
Content-Type: application/json

{
  "email": "john.doe@example.com",
  "password": "SecurePass123",
  "remember_me": false
}
```

#### 3. Token Validation

```http
POST /auth/validate
Authorization: Bearer <token>

{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

#### 4. Token Refresh

```http
POST /auth/refresh
Authorization: Bearer <token>
```

#### 5. Get User Profile

```http
GET /auth/profile
Authorization: Bearer <token>
```

#### 6. Update User Profile

```http
PUT /auth/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "first_name": "John",
  "last_name": "Smith",
  "phone": "+250788123456",
  "date_of_birth": "1990-01-01",
  "gender": "male"
}
```

#### 7. Change Password

```http
POST /auth/change-password
Authorization: Bearer <token>
Content-Type: application/json

{
  "current_password": "OldPassword123",
  "new_password": "NewPassword123"
}
```

### Test Endpoints

#### Database Connection Test

```http
GET /test/database
```

## 🔐 Authentication

The API uses JWT (JSON Web Tokens) for authentication. Include the token in the Authorization header:

```http
Authorization: Bearer <your-jwt-token>
```

### Token Expiration

- Default: 24 hours (86400 seconds)
- Remember Me: 7 days (604800 seconds)

## 🗄️ Database Schema

The backend connects to the existing `ikiraha_ordering_system` database with 52 tables including:

### Core Tables

- `users` - User accounts and profiles
- `user_roles` - Role-based access control
- `languages` - Multi-language support

### Authentication Fields

- `password_hash` - Bcrypt hashed passwords
- `email_verified_at` - Email verification timestamp
- `last_login_at` - Last login tracking
- `is_active` - Account status

## ❌ Error Handling

### Standard Error Response

```json
{
  "success": false,
  "message": "Error description",
  "error_code": 400,
  "timestamp": "2024-01-01 12:00:00"
}
```

### HTTP Status Codes

- `200` - Success
- `201` - Created (registration)
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (invalid credentials/token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found (endpoint not found)
- `429` - Too Many Requests (rate limiting)
- `500` - Internal Server Error

## 🧪 Testing

### Manual Testing with cURL

1. **Test Database Connection**

   ```bash
   curl -X GET http://localhost/ikiraha_mobile/backend/api/test/database
   ```

2. **Register User**

   ```bash
   curl -X POST http://localhost/ikiraha_mobile/backend/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{
       "first_name": "Test",
       "last_name": "User",
       "email": "test@example.com",
       "phone": "+250788123456",
       "password": "TestPass123"
     }'
   ```

3. **Login User**

   ```bash
   curl -X POST http://localhost/ikiraha_mobile/backend/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{
       "email": "test@example.com",
       "password": "TestPass123"
     }'
   ```

4. **Get Profile (with token)**
   ```bash
   curl -X GET http://localhost/ikiraha_mobile/backend/api/auth/profile \
     -H "Authorization: Bearer YOUR_TOKEN_HERE"
   ```

### Testing with Postman

Import the following collection for comprehensive testing:

1. Create a new Postman collection
2. Add environment variables:
   - `base_url`: `http://localhost/ikiraha_mobile/backend/api`
   - `token`: (will be set automatically after login)

## 🔧 Configuration

### Database Configuration

Edit `config/database.php`:

```php
private $host = 'localhost';
private $database = 'ikiraha_ordering_system';
private $username = 'root';
private $password = '';
```

### JWT Secret

Update the JWT secret in `services/AuthService.php`:

```php
private $jwtSecret = 'your-secure-secret-key';
```

## 📝 Logging

API access and errors are logged to:

- Access logs: `logs/api_access.log`
- Error logs: `logs/api_error.log`
- PHP error log: System default

## 🚀 Deployment

For production deployment:

1. **Update Configuration**

   - Change database credentials
   - Update JWT secret key
   - Enable HTTPS
   - Configure proper logging

2. **Security Hardening**

   - Remove error details from responses
   - Implement proper rate limiting
   - Add input sanitization
   - Configure firewall rules

3. **Performance Optimization**
   - Enable PHP OPcache
   - Configure database connection pooling
   - Implement Redis for session storage
   - Add CDN for static assets

## 📞 Support

For support and questions:

- Email: support@ikiraha.com
- Phone: +250788123456

## 📁 File Structure

```
backend/
├── api/
│   ├── auth/
│   │   ├── register.php          # User registration
│   │   ├── login.php             # User login
│   │   ├── validate.php          # Token validation
│   │   ├── refresh.php           # Token refresh
│   │   ├── profile.php           # User profile management
│   │   └── change-password.php   # Password change
│   ├── middleware/
│   │   └── auth_middleware.php   # Authentication middleware
│   ├── test/
│   │   └── database.php          # Database connection test
│   └── errors/
│       ├── 404.php               # Not found handler
│       └── 500.php               # Server error handler
├── config/
│   └── database.php              # Database configuration
├── services/
│   └── AuthService.php           # Authentication service
├── .htaccess                     # URL rewriting and CORS
└── README.md                     # This documentation
```

---

**Status**: ✅ Backend API Ready | ✅ Authentication System Complete | 🚧 Ready for Integration
