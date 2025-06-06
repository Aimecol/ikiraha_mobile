# CORS Error Fix Instructions

## Understanding the Error

The CORS error occurs because:
1. Your Flutter web app runs on `http://localhost:8082`
2. Your API should run on `http://localhost/ikiraha_api/`
3. The browser blocks cross-origin requests without proper CORS headers

## Quick Fix Options

### Option 1: Copy API to XAMPP (Recommended)

1. **Copy the backend folder to XAMPP:**
   ```bash
   # Copy the entire backend/ikiraha_api folder to your XAMPP htdocs directory
   # Example: C:\xampp\htdocs\ikiraha_api\
   ```

2. **Start XAMPP:**
   - Start Apache server in XAMPP Control Panel
   - Make sure it's running on port 80

3. **Test the API:**
   - Open browser and go to: `http://localhost/ikiraha_api/`
   - You should see: `{"success":true,"message":"Ikiraha Mobile API",...}`
   - Test restaurants endpoint: `http://localhost/ikiraha_api/restaurants`

### Option 2: Use Chrome with CORS Disabled (Development Only)

1. **Close all Chrome instances**

2. **Start Chrome with CORS disabled:**
   ```bash
   # Windows
   chrome.exe --user-data-dir="C:/Chrome dev session" --disable-web-security --disable-features=VizDisplayCompositor

   # Mac
   open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="/tmp/chrome_dev_test" --disable-web-security

   # Linux
   google-chrome --disable-web-security --user-data-dir="/tmp/chrome_dev_test"
   ```

3. **Run your Flutter app in this Chrome instance**

### Option 3: Use Flutter Web with Proxy (Advanced)

1. **Update your API configuration to use a proxy:**
   ```dart
   // In lib/config/database_config.dart
   static String get baseUrl {
     if (kIsWeb) {
       return '/api'; // Use relative URL for web
     }
     return 'http://localhost/ikiraha_api';
   }
   ```

2. **Configure Flutter web to proxy API requests**

## Current Status

✅ **API Files Created:**
- `backend/ikiraha_api/index.php` - Main router with CORS headers
- `backend/ikiraha_api/restaurants.php` - Restaurant endpoint with mock data
- `backend/ikiraha_api/.htaccess` - URL rewriting and CORS headers

✅ **CORS Headers Added:**
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS`
- `Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With`

✅ **Mock Data Available:**
- 5 sample restaurants with complete data
- Proper JSON structure matching your Flutter model
- Pagination support

## Next Steps

1. **Copy API to XAMPP** (easiest solution)
2. **Start XAMPP Apache server**
3. **Test API endpoints**
4. **Refresh your Flutter app**

## Testing the Fix

After setting up the API, you should see:
1. No more CORS errors in browser console
2. Restaurant data loading from the API
3. Responsive design working properly
4. All filtering and search functionality working

## Production Considerations

For production deployment:
1. Replace `Access-Control-Allow-Origin: *` with specific domains
2. Add authentication headers
3. Implement proper database connections
4. Add rate limiting and security measures
5. Use HTTPS for all API calls

## Troubleshooting

**If you still see CORS errors:**
1. Check that XAMPP Apache is running
2. Verify the API URL is correct
3. Check browser developer tools for exact error messages
4. Try accessing the API directly in browser

**If API returns 404:**
1. Check that files are in the correct XAMPP directory
2. Verify .htaccess file is present
3. Check XAMPP Apache configuration

**If data doesn't load:**
1. Check browser network tab for API calls
2. Verify JSON response format
3. Check Flutter console for parsing errors
