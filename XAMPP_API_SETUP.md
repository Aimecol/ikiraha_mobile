# XAMPP API Setup Instructions

## Problem Fixed
✅ **URL Duplication Issue**: Fixed the duplicate `/ikiraha_api/ikiraha_api/` in the API URLs
✅ **CORS Headers**: Added proper CORS support to the PHP backend
✅ **Mock Data API**: Created working PHP endpoints with restaurant data

## Quick Setup Steps

### 1. Copy API Files to XAMPP

Copy the files from `xampp_setup/ikiraha_api/` to your XAMPP htdocs directory:

**Windows:**
```bash
# Copy from project to XAMPP
xcopy /E /I "xampp_setup\ikiraha_api" "C:\xampp\htdocs\ikiraha_api"
```

**Manual Copy:**
1. Navigate to: `C:\xampp\htdocs\`
2. Create folder: `ikiraha_api`
3. Copy these files into it:
   - `index.php`
   - `restaurants.php`
   - `.htaccess`

### 2. Start XAMPP

1. Open XAMPP Control Panel
2. Start **Apache** (MySQL not needed for mock data)
3. Verify Apache is running on port 80

### 3. Test the API

Open browser and test these URLs:

1. **API Info**: `http://localhost/ikiraha_api/`
   - Should show: `{"success":true,"message":"Ikiraha Mobile API",...}`

2. **Restaurants**: `http://localhost/ikiraha_api/restaurants`
   - Should show: `{"success":true,"data":[...],"pagination":{...}}`

3. **With Filters**: `http://localhost/ikiraha_api/restaurants?search=pizza`
   - Should show filtered results

### 4. Test Your Flutter App

1. Refresh your Flutter app
2. You should see:
   - ✅ No CORS errors in console
   - ✅ Restaurant data loading from API
   - ✅ All responsive features working
   - ✅ Search and filtering working

## What Was Fixed

### 1. URL Duplication
**Before:** `http://localhost/ikiraha_api/ikiraha_api/restaurants`
**After:** `http://localhost/ikiraha_api/restaurants`

**Fixed in:** `lib/services/database_service.dart`
- Updated `getRestaurants()` method
- Updated `getUsers()` method
- Proper query parameter handling

### 2. CORS Headers
Added to all PHP files:
```php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
```

### 3. OPTIONS Request Handling
```php
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
```

## API Features

### Restaurant Endpoint: `/restaurants`

**Supported Parameters:**
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 20)
- `search` - Search in name, email, description
- `category` - Filter by category (Pizza, Fast Food, Asian, Italian, Healthy)
- `status` - Filter by status (active, inactive, open, closed)

**Example Requests:**
```
GET /restaurants
GET /restaurants?search=pizza
GET /restaurants?category=Italian
GET /restaurants?status=active
GET /restaurants?search=burger&status=open
```

**Response Format:**
```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "current_page": 1,
    "total_pages": 1,
    "total_count": 5,
    "per_page": 20
  },
  "timestamp": "2024-01-01 12:00:00"
}
```

## Troubleshooting

### If CORS errors persist:
1. Check XAMPP Apache is running
2. Verify files are in correct location
3. Check .htaccess file exists
4. Try restarting Apache

### If 404 errors:
1. Check URL: `http://localhost/ikiraha_api/` (not `http://localhost:8080/`)
2. Verify files copied correctly
3. Check Apache error logs

### If data doesn't load:
1. Check browser Network tab
2. Verify API returns JSON
3. Check Flutter console for errors

## Next Steps

1. ✅ **API Working**: Your API is now functional with mock data
2. 🔄 **Database Integration**: Later, replace mock data with real database queries
3. 🔄 **Authentication**: Add JWT token validation
4. 🔄 **Real CRUD**: Implement create, update, delete operations

Your Flutter app should now work perfectly with the API!
