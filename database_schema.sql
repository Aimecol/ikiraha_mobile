-- =====================================================
-- IKIRAHA MOBILE ORDERING SYSTEM DATABASE SCHEMA
-- Comprehensive normalized MySQL database for XAMPP
-- Features: Multi-user, Multi-language, Analytics, Recommendations, Admin
-- =====================================================

SET FOREIGN_KEY_CHECKS = 0;
DROP DATABASE IF EXISTS ikiraha_ordering_system;
CREATE DATABASE ikiraha_ordering_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ikiraha_ordering_system;

-- =====================================================
-- CORE SYSTEM TABLES
-- =====================================================

-- Languages table for multi-language support
CREATE TABLE languages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(5) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    native_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- User roles for role-based access control
CREATE TABLE user_roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    permissions JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Main users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) NOT NULL UNIQUE,
    role_id INT NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    gender ENUM('male', 'female', 'other', 'prefer_not_to_say'),
    profile_image VARCHAR(500),
    preferred_language_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    email_verified_at TIMESTAMP NULL,
    phone_verified_at TIMESTAMP NULL,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES user_roles(id),
    FOREIGN KEY (preferred_language_id) REFERENCES languages(id)
);

-- User addresses for delivery
CREATE TABLE user_addresses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    type ENUM('home', 'work', 'other') DEFAULT 'home',
    label VARCHAR(100),
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- User payment methods
CREATE TABLE user_payment_methods (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    type ENUM('credit_card', 'debit_card', 'paypal', 'mobile_money', 'bank_transfer', 'cash') NOT NULL,
    provider VARCHAR(50),
    masked_number VARCHAR(20),
    expiry_month INT,
    expiry_year INT,
    cardholder_name VARCHAR(255),
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =====================================================
-- RESTAURANT/VENDOR MANAGEMENT
-- =====================================================

-- Restaurant categories
CREATE TABLE restaurant_categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image VARCHAR(500),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Restaurants/Vendors
CREATE TABLE restaurants (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) NOT NULL UNIQUE,
    owner_id INT NOT NULL,
    category_id INT,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    logo VARCHAR(500),
    cover_image VARCHAR(500),
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    delivery_radius DECIMAL(5, 2) DEFAULT 10.00,
    minimum_order_amount DECIMAL(10, 2) DEFAULT 0.00,
    delivery_fee DECIMAL(10, 2) DEFAULT 0.00,
    estimated_delivery_time INT DEFAULT 30,
    rating DECIMAL(3, 2) DEFAULT 0.00,
    total_reviews INT DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    is_open BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES restaurant_categories(id)
);

-- Restaurant operating hours
CREATE TABLE restaurant_hours (
    id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT NOT NULL,
    day_of_week TINYINT NOT NULL, -- 0=Sunday, 1=Monday, ..., 6=Saturday
    open_time TIME,
    close_time TIME,
    is_closed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    UNIQUE KEY unique_restaurant_day (restaurant_id, day_of_week)
);

-- Restaurant cuisines/tags
CREATE TABLE cuisines (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    image VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Restaurant-cuisine relationship
CREATE TABLE restaurant_cuisines (
    id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT NOT NULL,
    cuisine_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (cuisine_id) REFERENCES cuisines(id) ON DELETE CASCADE,
    UNIQUE KEY unique_restaurant_cuisine (restaurant_id, cuisine_id)
);

-- =====================================================
-- PRODUCT/MENU MANAGEMENT
-- =====================================================

-- Product categories
CREATE TABLE product_categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image VARCHAR(500),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

-- Products/Menu items
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) NOT NULL UNIQUE,
    restaurant_id INT NOT NULL,
    category_id INT,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    image VARCHAR(500),
    price DECIMAL(10, 2) NOT NULL,
    compare_price DECIMAL(10, 2),
    cost_price DECIMAL(10, 2),
    sku VARCHAR(100),
    barcode VARCHAR(100),
    weight DECIMAL(8, 3),
    dimensions VARCHAR(100),
    calories INT,
    preparation_time INT DEFAULT 15,
    is_vegetarian BOOLEAN DEFAULT FALSE,
    is_vegan BOOLEAN DEFAULT FALSE,
    is_gluten_free BOOLEAN DEFAULT FALSE,
    is_spicy BOOLEAN DEFAULT FALSE,
    spice_level TINYINT DEFAULT 0, -- 0-5 scale
    allergens JSON,
    ingredients JSON,
    nutritional_info JSON,
    sort_order INT DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES product_categories(id),
    INDEX idx_restaurant_category (restaurant_id, category_id),
    INDEX idx_slug (slug),
    INDEX idx_featured (is_featured),
    INDEX idx_available (is_available)
);

-- Product variants (sizes, colors, etc.)
CREATE TABLE product_variants (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    price_adjustment DECIMAL(10, 2) DEFAULT 0.00,
    sku VARCHAR(100),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Product add-ons/extras
CREATE TABLE product_addons (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    is_required BOOLEAN DEFAULT FALSE,
    max_quantity INT DEFAULT 1,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Product images gallery
CREATE TABLE product_images (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    sort_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- =====================================================
-- MULTI-LANGUAGE CONTENT TABLES
-- =====================================================

-- Restaurant translations
CREATE TABLE restaurant_translations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT NOT NULL,
    language_id INT NOT NULL,
    name VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY unique_restaurant_language (restaurant_id, language_id)
);

-- Product translations
CREATE TABLE product_translations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    language_id INT NOT NULL,
    name VARCHAR(255),
    description TEXT,
    short_description VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY unique_product_language (product_id, language_id)
);

-- Category translations
CREATE TABLE category_translations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT NOT NULL,
    category_type ENUM('restaurant', 'product') NOT NULL,
    language_id INT NOT NULL,
    name VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY unique_category_language (category_id, category_type, language_id)
);

-- =====================================================
-- ORDER MANAGEMENT SYSTEM
-- =====================================================

-- Order statuses
CREATE TABLE order_statuses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7), -- Hex color code
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Main orders table
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) NOT NULL UNIQUE,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    status_id INT NOT NULL,
    order_type ENUM('delivery', 'pickup', 'dine_in') DEFAULT 'delivery',
    payment_method_id INT,
    delivery_address_id INT,
    subtotal DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) DEFAULT 0.00,
    delivery_fee DECIMAL(10, 2) DEFAULT 0.00,
    service_fee DECIMAL(10, 2) DEFAULT 0.00,
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    tip_amount DECIMAL(10, 2) DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    special_instructions TEXT,
    estimated_delivery_time TIMESTAMP NULL,
    actual_delivery_time TIMESTAMP NULL,
    scheduled_for TIMESTAMP NULL,
    rating TINYINT,
    review TEXT,
    reviewed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id),
    FOREIGN KEY (status_id) REFERENCES order_statuses(id),
    FOREIGN KEY (payment_method_id) REFERENCES user_payment_methods(id),
    FOREIGN KEY (delivery_address_id) REFERENCES user_addresses(id),
    INDEX idx_customer (customer_id),
    INDEX idx_restaurant (restaurant_id),
    INDEX idx_status (status_id),
    INDEX idx_order_date (created_at),
    INDEX idx_order_number (order_number)
);

-- Order items
CREATE TABLE order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    variant_id INT,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (variant_id) REFERENCES product_variants(id)
);

-- Order item add-ons
CREATE TABLE order_item_addons (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_item_id INT NOT NULL,
    addon_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE CASCADE,
    FOREIGN KEY (addon_id) REFERENCES product_addons(id)
);

-- Order status history
CREATE TABLE order_status_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    status_id INT NOT NULL,
    changed_by INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (status_id) REFERENCES order_statuses(id),
    FOREIGN KEY (changed_by) REFERENCES users(id)
);

-- =====================================================
-- PAYMENT AND TRANSACTION MANAGEMENT
-- =====================================================

-- Payment transactions
CREATE TABLE payment_transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    uuid VARCHAR(36) NOT NULL UNIQUE,
    order_id INT NOT NULL,
    payment_method_id INT,
    transaction_id VARCHAR(255),
    gateway VARCHAR(50),
    type ENUM('payment', 'refund', 'partial_refund') DEFAULT 'payment',
    status ENUM('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded') DEFAULT 'pending',
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    gateway_response JSON,
    processed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (payment_method_id) REFERENCES user_payment_methods(id),
    INDEX idx_order (order_id),
    INDEX idx_status (status),
    INDEX idx_transaction_id (transaction_id)
);

-- =====================================================
-- DELIVERY MANAGEMENT
-- =====================================================

-- Delivery drivers
CREATE TABLE delivery_drivers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    license_number VARCHAR(50),
    vehicle_type ENUM('bicycle', 'motorcycle', 'car', 'van') NOT NULL,
    vehicle_model VARCHAR(100),
    vehicle_plate VARCHAR(20),
    is_available BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    rating DECIMAL(3, 2) DEFAULT 0.00,
    total_deliveries INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Delivery assignments
CREATE TABLE delivery_assignments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    driver_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    picked_up_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    distance_km DECIMAL(8, 2),
    delivery_notes TEXT,
    customer_rating TINYINT,
    customer_feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (driver_id) REFERENCES delivery_drivers(id),
    INDEX idx_order (order_id),
    INDEX idx_driver (driver_id)
);

-- Driver location tracking
CREATE TABLE driver_locations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    driver_id INT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    accuracy DECIMAL(8, 2),
    speed DECIMAL(8, 2),
    heading DECIMAL(5, 2),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (driver_id) REFERENCES delivery_drivers(id) ON DELETE CASCADE,
    INDEX idx_driver_time (driver_id, recorded_at)
);

-- =====================================================
-- PROMOTIONS AND DISCOUNTS
-- =====================================================

-- Discount types
CREATE TABLE discount_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Coupons and promotions
CREATE TABLE coupons (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type ENUM('percentage', 'fixed_amount', 'free_delivery', 'buy_x_get_y') NOT NULL,
    value DECIMAL(10, 2) NOT NULL,
    minimum_order_amount DECIMAL(10, 2) DEFAULT 0.00,
    maximum_discount_amount DECIMAL(10, 2),
    usage_limit INT,
    usage_limit_per_user INT DEFAULT 1,
    used_count INT DEFAULT 0,
    applicable_to ENUM('all', 'restaurant', 'category', 'product') DEFAULT 'all',
    applicable_ids JSON, -- Store restaurant/category/product IDs
    valid_from DATETIME NOT NULL,
    valid_until DATETIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_code (code),
    INDEX idx_validity (valid_from, valid_until),
    INDEX idx_active (is_active)
);

-- Coupon usage tracking
CREATE TABLE coupon_usage (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coupon_id INT NOT NULL,
    user_id INT NOT NULL,
    order_id INT NOT NULL,
    discount_amount DECIMAL(10, 2) NOT NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (coupon_id) REFERENCES coupons(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    UNIQUE KEY unique_coupon_order (coupon_id, order_id)
);

-- =====================================================
-- CUSTOMER BEHAVIOR ANALYSIS TABLES
-- =====================================================

-- User activity tracking
CREATE TABLE user_activities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    session_id VARCHAR(255),
    activity_type ENUM('login', 'logout', 'view_restaurant', 'view_product', 'add_to_cart', 'remove_from_cart', 'search', 'filter', 'place_order', 'cancel_order', 'rate_order', 'app_open', 'app_close') NOT NULL,
    entity_type ENUM('restaurant', 'product', 'category', 'order', 'search') NULL,
    entity_id INT NULL,
    metadata JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    device_type ENUM('mobile', 'tablet', 'desktop') DEFAULT 'mobile',
    platform ENUM('ios', 'android', 'web') DEFAULT 'android',
    app_version VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_activity (user_id, activity_type),
    INDEX idx_session (session_id),
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_created_at (created_at)
);

-- User preferences tracking
CREATE TABLE user_preferences (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    preference_type ENUM('cuisine', 'dietary', 'price_range', 'delivery_time', 'restaurant', 'product_category') NOT NULL,
    preference_value VARCHAR(255) NOT NULL,
    weight DECIMAL(3, 2) DEFAULT 1.00, -- Preference strength
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_preference (user_id, preference_type, preference_value)
);

-- User search history
CREATE TABLE user_searches (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    search_query VARCHAR(500) NOT NULL,
    filters JSON,
    results_count INT DEFAULT 0,
    clicked_result_id INT,
    clicked_result_type ENUM('restaurant', 'product'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_search (user_id, created_at),
    INDEX idx_search_query (search_query)
);

-- User cart abandonment tracking
CREATE TABLE cart_abandonments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    session_id VARCHAR(255),
    restaurant_id INT,
    items_count INT NOT NULL,
    total_value DECIMAL(10, 2) NOT NULL,
    abandonment_stage ENUM('cart', 'checkout', 'payment') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE SET NULL,
    INDEX idx_user_abandonment (user_id, created_at),
    INDEX idx_restaurant_abandonment (restaurant_id, created_at)
);

-- =====================================================
-- RECOMMENDATION SYSTEM TABLES
-- =====================================================

-- Product recommendations
CREATE TABLE product_recommendations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    product_id INT NOT NULL,
    recommendation_type ENUM('collaborative', 'content_based', 'popular', 'trending', 'personalized', 'similar_users', 'frequently_bought_together') NOT NULL,
    score DECIMAL(5, 4) NOT NULL,
    reason TEXT,
    metadata JSON,
    is_clicked BOOLEAN DEFAULT FALSE,
    is_ordered BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_user_recommendations (user_id, score DESC),
    INDEX idx_product_recommendations (product_id),
    INDEX idx_type_score (recommendation_type, score DESC),
    INDEX idx_expires (expires_at)
);

-- Restaurant recommendations
CREATE TABLE restaurant_recommendations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    restaurant_id INT NOT NULL,
    recommendation_type ENUM('location_based', 'cuisine_preference', 'rating_based', 'popular', 'trending', 'similar_users', 'new_restaurant') NOT NULL,
    score DECIMAL(5, 4) NOT NULL,
    reason TEXT,
    metadata JSON,
    is_clicked BOOLEAN DEFAULT FALSE,
    is_ordered BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    INDEX idx_user_recommendations (user_id, score DESC),
    INDEX idx_restaurant_recommendations (restaurant_id),
    INDEX idx_type_score (recommendation_type, score DESC),
    INDEX idx_expires (expires_at)
);

-- User similarity matrix for collaborative filtering
CREATE TABLE user_similarities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_a_id INT NOT NULL,
    user_b_id INT NOT NULL,
    similarity_score DECIMAL(5, 4) NOT NULL,
    similarity_type ENUM('cosine', 'pearson', 'jaccard') DEFAULT 'cosine',
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_a_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (user_b_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_pair (user_a_id, user_b_id),
    INDEX idx_user_similarity (user_a_id, similarity_score DESC)
);

-- Product similarity matrix
CREATE TABLE product_similarities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_a_id INT NOT NULL,
    product_b_id INT NOT NULL,
    similarity_score DECIMAL(5, 4) NOT NULL,
    similarity_type ENUM('content', 'collaborative', 'hybrid') DEFAULT 'content',
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_a_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (product_b_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_product_pair (product_a_id, product_b_id),
    INDEX idx_product_similarity (product_a_id, similarity_score DESC)
);

-- =====================================================
-- ADMIN AND ANALYTICS TABLES
-- =====================================================

-- System settings
CREATE TABLE system_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    setting_type ENUM('string', 'integer', 'decimal', 'boolean', 'json') DEFAULT 'string',
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Admin activity logs
CREATE TABLE admin_activity_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    admin_id INT NOT NULL,
    action ENUM('create', 'update', 'delete', 'login', 'logout', 'export', 'import', 'approve', 'reject', 'suspend', 'activate') NOT NULL,
    entity_type ENUM('user', 'restaurant', 'product', 'order', 'coupon', 'category', 'setting', 'report') NOT NULL,
    entity_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES users(id),
    INDEX idx_admin_activity (admin_id, created_at),
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_action (action)
);

-- Revenue analytics
CREATE TABLE revenue_analytics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    date DATE NOT NULL,
    restaurant_id INT,
    total_orders INT DEFAULT 0,
    total_revenue DECIMAL(12, 2) DEFAULT 0.00,
    total_commission DECIMAL(12, 2) DEFAULT 0.00,
    total_delivery_fees DECIMAL(12, 2) DEFAULT 0.00,
    total_tips DECIMAL(12, 2) DEFAULT 0.00,
    average_order_value DECIMAL(10, 2) DEFAULT 0.00,
    new_customers INT DEFAULT 0,
    returning_customers INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    UNIQUE KEY unique_date_restaurant (date, restaurant_id),
    INDEX idx_date (date),
    INDEX idx_restaurant_date (restaurant_id, date)
);

-- Product analytics
CREATE TABLE product_analytics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    date DATE NOT NULL,
    product_id INT NOT NULL,
    views INT DEFAULT 0,
    orders INT DEFAULT 0,
    revenue DECIMAL(10, 2) DEFAULT 0.00,
    conversion_rate DECIMAL(5, 4) DEFAULT 0.0000,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_date_product (date, product_id),
    INDEX idx_date (date),
    INDEX idx_product_date (product_id, date)
);

-- =====================================================
-- REVIEWS AND RATINGS SYSTEM
-- =====================================================

-- Restaurant reviews
CREATE TABLE restaurant_reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT NOT NULL,
    user_id INT NOT NULL,
    order_id INT,
    rating TINYINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    food_rating TINYINT CHECK (food_rating >= 1 AND food_rating <= 5),
    service_rating TINYINT CHECK (service_rating >= 1 AND service_rating <= 5),
    delivery_rating TINYINT CHECK (delivery_rating >= 1 AND delivery_rating <= 5),
    is_verified BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    admin_response TEXT,
    admin_response_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL,
    INDEX idx_restaurant_rating (restaurant_id, rating),
    INDEX idx_user_reviews (user_id),
    INDEX idx_featured (is_featured)
);

-- Product reviews
CREATE TABLE product_reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    order_id INT,
    rating TINYINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    helpful_votes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL,
    INDEX idx_product_rating (product_id, rating),
    INDEX idx_user_reviews (user_id)
);

-- Review helpfulness votes
CREATE TABLE review_votes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    review_id INT NOT NULL,
    review_type ENUM('restaurant', 'product') NOT NULL,
    user_id INT NOT NULL,
    is_helpful BOOLEAN NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_review_vote (review_id, review_type, user_id)
);

-- =====================================================
-- NOTIFICATIONS SYSTEM
-- =====================================================

-- Notification templates
CREATE TABLE notification_templates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    type ENUM('email', 'sms', 'push', 'in_app') NOT NULL,
    subject VARCHAR(255),
    content TEXT NOT NULL,
    variables JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- User notifications
CREATE TABLE user_notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    type ENUM('order_status', 'promotion', 'recommendation', 'system', 'marketing') NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSON,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_notifications (user_id, is_read, created_at),
    INDEX idx_type (type)
);

-- Push notification tokens
CREATE TABLE push_notification_tokens (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    device_token VARCHAR(500) NOT NULL,
    platform ENUM('ios', 'android', 'web') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_token (user_id, device_token)
);

-- =====================================================
-- INVENTORY MANAGEMENT
-- =====================================================

-- Product inventory
CREATE TABLE product_inventory (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    variant_id INT,
    quantity_available INT NOT NULL DEFAULT 0,
    quantity_reserved INT NOT NULL DEFAULT 0,
    low_stock_threshold INT DEFAULT 10,
    is_unlimited BOOLEAN DEFAULT FALSE,
    last_restocked_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE CASCADE,
    UNIQUE KEY unique_product_variant (product_id, variant_id)
);

-- Inventory movements
CREATE TABLE inventory_movements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    variant_id INT,
    movement_type ENUM('in', 'out', 'adjustment', 'reserved', 'released') NOT NULL,
    quantity INT NOT NULL,
    reason VARCHAR(255),
    reference_type ENUM('order', 'restock', 'adjustment', 'expired', 'damaged') NOT NULL,
    reference_id INT,
    performed_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE CASCADE,
    FOREIGN KEY (performed_by) REFERENCES users(id),
    INDEX idx_product_movement (product_id, created_at),
    INDEX idx_reference (reference_type, reference_id)
);

-- =====================================================
-- LOYALTY AND REWARDS SYSTEM
-- =====================================================

-- Loyalty programs
CREATE TABLE loyalty_programs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    points_per_dollar DECIMAL(5, 2) DEFAULT 1.00,
    redemption_rate DECIMAL(5, 2) DEFAULT 0.01, -- Points to dollar conversion
    minimum_redemption_points INT DEFAULT 100,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

-- User loyalty points
CREATE TABLE user_loyalty_points (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    program_id INT NOT NULL,
    points_balance INT DEFAULT 0,
    points_earned INT DEFAULT 0,
    points_redeemed INT DEFAULT 0,
    tier_level ENUM('bronze', 'silver', 'gold', 'platinum') DEFAULT 'bronze',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (program_id) REFERENCES loyalty_programs(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_program (user_id, program_id)
);

-- Loyalty point transactions
CREATE TABLE loyalty_point_transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    program_id INT NOT NULL,
    order_id INT,
    transaction_type ENUM('earned', 'redeemed', 'expired', 'adjusted') NOT NULL,
    points INT NOT NULL,
    description VARCHAR(255),
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (program_id) REFERENCES loyalty_programs(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL,
    INDEX idx_user_program (user_id, program_id, created_at)
);

-- =====================================================
-- ADDITIONAL INDEXES FOR PERFORMANCE
-- =====================================================

-- Additional indexes for better query performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_restaurants_location ON restaurants(latitude, longitude);
CREATE INDEX idx_restaurants_active ON restaurants(is_active, is_open);
CREATE INDEX idx_products_restaurant_active ON products(restaurant_id, is_active, is_available);
CREATE INDEX idx_orders_customer_date ON orders(customer_id, created_at);
CREATE INDEX idx_orders_restaurant_date ON orders(restaurant_id, created_at);
CREATE INDEX idx_user_activities_date ON user_activities(created_at);

-- =====================================================
-- SAMPLE DATA INSERTION
-- =====================================================

SET FOREIGN_KEY_CHECKS = 1;

-- Insert default languages
INSERT INTO languages (code, name, native_name, is_default) VALUES
('en', 'English', 'English', TRUE),
('fr', 'French', 'Français', FALSE),
('es', 'Spanish', 'Español', FALSE),
('rw', 'Kinyarwanda', 'Ikinyarwanda', FALSE),
('sw', 'Swahili', 'Kiswahili', FALSE);

-- Insert user roles
INSERT INTO user_roles (name, description, permissions) VALUES
('super_admin', 'Super Administrator with full access', '{"all": true}'),
('admin', 'System Administrator', '{"users": ["read", "create", "update"], "restaurants": ["read", "create", "update"], "orders": ["read", "update"], "analytics": ["read"]}'),
('restaurant_owner', 'Restaurant Owner', '{"own_restaurant": ["read", "update"], "own_products": ["read", "create", "update", "delete"], "own_orders": ["read", "update"]}'),
('restaurant_manager', 'Restaurant Manager', '{"own_restaurant": ["read"], "own_products": ["read", "update"], "own_orders": ["read", "update"]}'),
('delivery_driver', 'Delivery Driver', '{"own_deliveries": ["read", "update"], "location": ["update"]}'),
('customer', 'Regular Customer', '{"profile": ["read", "update"], "orders": ["create", "read"], "reviews": ["create", "read", "update"]}');

-- Insert order statuses
INSERT INTO order_statuses (name, description, color, sort_order) VALUES
('pending', 'Order placed, waiting for confirmation', '#FFA500', 1),
('confirmed', 'Order confirmed by restaurant', '#2196F3', 2),
('preparing', 'Order is being prepared', '#FF9800', 3),
('ready', 'Order ready for pickup/delivery', '#4CAF50', 4),
('picked_up', 'Order picked up by driver', '#9C27B0', 5),
('delivered', 'Order delivered to customer', '#4CAF50', 6),
('cancelled', 'Order cancelled', '#F44336', 7),
('refunded', 'Order refunded', '#607D8B', 8);

-- Insert discount types
INSERT INTO discount_types (name, description) VALUES
('percentage', 'Percentage-based discount'),
('fixed_amount', 'Fixed amount discount'),
('free_delivery', 'Free delivery discount'),
('buy_x_get_y', 'Buy X get Y free discount');

-- Insert restaurant categories
INSERT INTO restaurant_categories (name, description, sort_order) VALUES
('Fast Food', 'Quick service restaurants', 1),
('Pizza', 'Pizza restaurants and pizzerias', 2),
('Asian', 'Asian cuisine restaurants', 3),
('Italian', 'Italian cuisine restaurants', 4),
('Mexican', 'Mexican cuisine restaurants', 5),
('Indian', 'Indian cuisine restaurants', 6),
('Healthy', 'Health-focused restaurants', 7),
('Desserts', 'Dessert and sweet shops', 8),
('Coffee & Tea', 'Coffee shops and tea houses', 9),
('Local Cuisine', 'Traditional local food', 10);

-- Insert cuisines
INSERT INTO cuisines (name, description) VALUES
('American', 'Traditional American cuisine'),
('Italian', 'Italian dishes and pasta'),
('Chinese', 'Chinese cuisine'),
('Indian', 'Indian spices and curries'),
('Mexican', 'Mexican and Tex-Mex food'),
('Japanese', 'Japanese cuisine including sushi'),
('Thai', 'Thai cuisine'),
('Mediterranean', 'Mediterranean dishes'),
('French', 'French cuisine'),
('African', 'Traditional African dishes'),
('Vegetarian', 'Vegetarian-friendly options'),
('Vegan', 'Plant-based options'),
('Gluten-Free', 'Gluten-free options'),
('Halal', 'Halal-certified food'),
('Kosher', 'Kosher-certified food');

-- Insert notification templates
INSERT INTO notification_templates (name, type, subject, content, variables) VALUES
('order_confirmed', 'push', 'Order Confirmed', 'Your order #{order_number} has been confirmed and is being prepared.', '["order_number", "restaurant_name", "estimated_time"]'),
('order_ready', 'push', 'Order Ready', 'Your order #{order_number} is ready for pickup/delivery.', '["order_number", "restaurant_name"]'),
('order_delivered', 'push', 'Order Delivered', 'Your order #{order_number} has been delivered. Enjoy your meal!', '["order_number", "restaurant_name"]'),
('new_promotion', 'push', 'Special Offer', 'Get {discount}% off your next order at {restaurant_name}!', '["discount", "restaurant_name", "coupon_code"]'),
('welcome_email', 'email', 'Welcome to Ikiraha!', 'Welcome to Ikiraha! Start exploring amazing restaurants in your area.', '["user_name"]');

-- Insert system settings
INSERT INTO system_settings (setting_key, setting_value, setting_type, description, is_public) VALUES
('app_name', 'Ikiraha', 'string', 'Application name', TRUE),
('app_version', '1.0.0', 'string', 'Current application version', TRUE),
('default_currency', 'USD', 'string', 'Default currency code', TRUE),
('default_language', 'en', 'string', 'Default language code', TRUE),
('commission_rate', '15.00', 'decimal', 'Platform commission rate percentage', FALSE),
('delivery_radius', '25.00', 'decimal', 'Maximum delivery radius in kilometers', TRUE),
('minimum_order_amount', '10.00', 'decimal', 'Minimum order amount', TRUE),
('max_delivery_time', '120', 'integer', 'Maximum delivery time in minutes', TRUE),
('customer_support_email', 'support@ikiraha.com', 'string', 'Customer support email', TRUE),
('customer_support_phone', '+250788123456', 'string', 'Customer support phone', TRUE);

-- Create a default loyalty program
INSERT INTO loyalty_programs (restaurant_id, name, description, points_per_dollar, redemption_rate) VALUES
(NULL, 'Ikiraha Rewards', 'Platform-wide loyalty program', 1.00, 0.01);

COMMIT;
