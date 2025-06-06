# CORS Setup Guide for Ikiraha API

## Understanding the CORS Error

### What Happened?
```
Access to fetch at 'http://localhost/ikiraha_api/users' from origin 'http://localhost:52695' 
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present
```

### Why This Occurs:
1. **Different Origins**: Flutter web app (`localhost:52695`) ≠ PHP API (`localhost:80`)
2. **Browser Security**: Browsers block cross-origin requests by default
3. **Missing Headers**: Backend doesn't send CORS headers to allow the request

## Quick Fix Solutions

### Option 1: Add CORS Headers to PHP Backend (Recommended)

#### Step 1: Create CORS Middleware
Create `cors.php` in your API root:

```php
<?php
// cors.php - Add to your API root directory

function handleCors() {
    // Allow Flutter web app origins
    $allowedOrigins = [
        'http://localhost:52695',
        'http://localhost:3000',
        'http://127.0.0.1:52695',
        'http://127.0.0.1:3000'
    ];
    
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    
    if (in_array($origin, $allowedOrigins)) {
        header("Access-Control-Allow-Origin: $origin");
    }
    
    header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
    header("Access-Control-Allow-Credentials: true");
    
    // Handle preflight requests
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit();
    }
}

// Call this function at the start of every API file
handleCors();
?>
```

#### Step 2: Update Your API Entry Point
Add to the top of your main API file (e.g., `index.php`):

```php
<?php
// Include CORS handler
require_once 'cors.php';

// Your existing API code here...
?>
```

#### Step 3: Create Users Endpoint
Create `users.php` or add to your routing:

```php
<?php
require_once 'cors.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Sample users data
    $users = [
        [
            'id' => 1,
            'uuid' => 'uuid-1',
            'email' => 'admin@ikiraha.com',
            'first_name' => 'John',
            'last_name' => 'Admin',
            'role_name' => 'admin',
            'is_active' => true,
            'is_verified' => true,
            'phone' => '+250788123456',
            'created_at' => '2024-01-01T00:00:00Z',
            'updated_at' => '2024-01-01T00:00:00Z',
        ]
        // Add more users...
    ];
    
    echo json_encode([
        'success' => true,
        'data' => $users,
        'pagination' => [
            'current_page' => 1,
            'total_pages' => 1,
            'total_count' => count($users),
            'per_page' => 20,
        ]
    ]);
}
?>
```

### Option 2: Use Browser with Disabled Security (Development Only)

#### Chrome with Disabled CORS:
```bash
# Windows
chrome.exe --user-data-dir=/tmp/chrome_dev_session --disable-web-security --disable-features=VizDisplayCompositor

# macOS
open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="/tmp/chrome_dev_session" --disable-web-security

# Linux
google-chrome --user-data-dir="/tmp/chrome_dev_session" --disable-web-security
```

⚠️ **Warning**: Only use this for development. Never disable CORS in production!

### Option 3: Use Flutter Desktop/Mobile (No CORS Issues)

CORS only affects web browsers. Flutter desktop and mobile apps don't have CORS restrictions:

```bash
# Run on desktop (no CORS issues)
flutter run -d windows
flutter run -d macos
flutter run -d linux

# Run on mobile (no CORS issues)
flutter run -d android
flutter run -d ios
```

## Backend API Structure

### Recommended File Structure:
```
ikiraha_api/
├── cors.php                 # CORS handler
├── index.php               # Main entry point
├── config/
│   ├── database.php        # Database connection
│   └── config.php          # App configuration
├── endpoints/
│   ├── users.php           # User management
│   ├── auth.php            # Authentication
│   ├── restaurants.php     # Restaurant management
│   └── orders.php          # Order management
└── middleware/
    ├── auth.php            # Authentication middleware
    └── validation.php      # Input validation
```

### Sample API Response Format:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "uuid": "uuid-1",
      "email": "admin@ikiraha.com",
      "first_name": "John",
      "last_name": "Admin",
      "role_name": "admin",
      "is_active": true,
      "is_verified": true,
      "phone": "+250788123456",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 1,
    "total_count": 8,
    "per_page": 20
  }
}
```

## Testing Your CORS Fix

### 1. Test with Browser Developer Tools:
1. Open browser developer tools (F12)
2. Go to Network tab
3. Refresh your Flutter web app
4. Look for the API request
5. Check if CORS error is gone

### 2. Test with curl:
```bash
# Test OPTIONS request (preflight)
curl -X OPTIONS \
  -H "Origin: http://localhost:52695" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v http://localhost/ikiraha_api/users

# Test actual GET request
curl -X GET \
  -H "Origin: http://localhost:52695" \
  -v http://localhost/ikiraha_api/users
```

### 3. Verify Headers in Response:
Look for these headers in the response:
```
Access-Control-Allow-Origin: http://localhost:52695
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With
```

## Common CORS Issues & Solutions

### Issue 1: "No 'Access-Control-Allow-Origin' header"
**Solution**: Add the CORS headers to your PHP backend

### Issue 2: "CORS policy: Request header field authorization is not allowed"
**Solution**: Add `Authorization` to `Access-Control-Allow-Headers`

### Issue 3: "CORS policy: Method PUT is not allowed"
**Solution**: Add `PUT` to `Access-Control-Allow-Methods`

### Issue 4: Preflight request fails
**Solution**: Handle OPTIONS requests in your backend

## Production Considerations

### Security Best Practices:
1. **Specific Origins**: Don't use `*` for `Access-Control-Allow-Origin`
2. **HTTPS Only**: Use HTTPS in production
3. **Limited Headers**: Only allow necessary headers
4. **Authentication**: Implement proper API authentication

### Production CORS Configuration:
```php
// Production CORS settings
$allowedOrigins = [
    'https://yourdomain.com',
    'https://app.yourdomain.com'
];

// Never use '*' in production with credentials
header("Access-Control-Allow-Origin: https://yourdomain.com");
```

## Alternative Solutions

### 1. Proxy Server (Development)
Use a proxy server to avoid CORS during development:

```bash
# Using http-proxy-middleware with Node.js
npm install -g http-proxy-middleware
```

### 2. Backend Proxy Endpoint
Create a proxy endpoint in your backend that makes the actual API calls.

### 3. Use Flutter Web with --web-renderer html
```bash
flutter run -d chrome --web-renderer html
```

## Conclusion

The CORS error is a common issue when developing web applications. The recommended solution is to properly configure CORS headers in your PHP backend. This ensures your Flutter web app can communicate with your API while maintaining security best practices.

For immediate testing, you can use Flutter desktop/mobile builds which don't have CORS restrictions, or temporarily disable browser security for development only.
