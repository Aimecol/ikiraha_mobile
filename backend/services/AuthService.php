<?php
require_once __DIR__ . '/../config/database.php';

/**
 * Authentication Service for Ikiraha Mobile Backend
 * Handles user registration, login, token management, and session handling
 */
class AuthService {
    private $db;
    private $jwtSecret;
    
    public function __construct() {
        $this->db = new Database();
        $this->jwtSecret = 'ikiraha_mobile_jwt_secret_key_2024'; // In production, use environment variable
    }

    /**
     * Register a new user
     */
    public function register($userData) {
        try {
            // Validate input data
            $validation = $this->validateRegistrationData($userData);
            if (!$validation['valid']) {
                return DatabaseUtils::formatResponse(false, 'Validation failed', null, $validation['errors']);
            }

            // Check if user already exists
            if ($this->userExists($userData['email'])) {
                return DatabaseUtils::formatResponse(false, 'User with this email already exists');
            }

            // Check if phone number already exists
            if ($this->phoneExists($userData['phone'])) {
                return DatabaseUtils::formatResponse(false, 'User with this phone number already exists');
            }

            // Get customer role ID
            $customerRole = $this->getRoleByName('customer');
            if (!$customerRole) {
                return DatabaseUtils::formatResponse(false, 'Customer role not found in database');
            }

            // Begin transaction
            $this->db->beginTransaction();

            try {
                // Generate UUID for user
                $userUuid = DatabaseUtils::generateUUID();
                
                // Hash password
                $hashedPassword = DatabaseUtils::hashPassword($userData['password']);

                // Insert user into database
                $sql = "INSERT INTO users (
                    uuid, role_id, email, phone, password_hash, 
                    first_name, last_name, is_active, created_at
                ) VALUES (
                    :uuid, :role_id, :email, :phone, :password_hash,
                    :first_name, :last_name, 1, NOW()
                )";

                $params = [
                    ':uuid' => $userUuid,
                    ':role_id' => $customerRole['id'],
                    ':email' => $userData['email'],
                    ':phone' => $userData['phone'],
                    ':password_hash' => $hashedPassword,
                    ':first_name' => $userData['first_name'],
                    ':last_name' => $userData['last_name']
                ];

                $this->db->query($sql, $params);
                $userId = $this->db->lastInsertId();

                // Generate access token
                $token = $this->generateJWT($userId, $userData['email']);

                // Commit transaction
                $this->db->commit();

                // Return success response with user data
                $userData = $this->getUserById($userId);
                unset($userData['password_hash']); // Remove password from response

                return DatabaseUtils::formatResponse(true, 'User registered successfully', [
                    'user' => $userData,
                    'token' => $token,
                    'expires_in' => 86400 // 24 hours
                ]);

            } catch (Exception $e) {
                $this->db->rollback();
                throw $e;
            }

        } catch (Exception $e) {
            return DatabaseUtils::formatResponse(false, 'Registration failed: ' . $e->getMessage());
        }
    }

    /**
     * Login user
     */
    public function login($email, $password, $rememberMe = false) {
        try {
            // Validate input
            if (empty($email) || empty($password)) {
                return DatabaseUtils::formatResponse(false, 'Email and password are required');
            }

            if (!DatabaseUtils::validateEmail($email)) {
                return DatabaseUtils::formatResponse(false, 'Invalid email format');
            }

            // Get user by email
            $user = $this->getUserByEmail($email);
            if (!$user) {
                return DatabaseUtils::formatResponse(false, 'Invalid email or password');
            }

            // Check if user is active
            if (!$user['is_active']) {
                return DatabaseUtils::formatResponse(false, 'Account is deactivated. Please contact support.');
            }

            // Verify password
            if (!DatabaseUtils::verifyPassword($password, $user['password_hash'])) {
                return DatabaseUtils::formatResponse(false, 'Invalid email or password');
            }

            // Update last login time
            $this->updateLastLogin($user['id']);

            // Generate access token
            $expiresIn = $rememberMe ? 604800 : 86400; // 7 days if remember me, otherwise 24 hours
            $token = $this->generateJWT($user['id'], $user['email'], $expiresIn);

            // Remove sensitive data from response
            unset($user['password_hash']);

            return DatabaseUtils::formatResponse(true, 'Login successful', [
                'user' => $user,
                'token' => $token,
                'expires_in' => $expiresIn
            ]);

        } catch (Exception $e) {
            return DatabaseUtils::formatResponse(false, 'Login failed: ' . $e->getMessage());
        }
    }

    /**
     * Validate JWT token
     */
    public function validateToken($token) {
        try {
            $decoded = $this->decodeJWT($token);
            
            if (!$decoded) {
                return DatabaseUtils::formatResponse(false, 'Invalid token');
            }

            // Check if user still exists and is active
            $user = $this->getUserById($decoded['user_id']);
            if (!$user || !$user['is_active']) {
                return DatabaseUtils::formatResponse(false, 'User not found or inactive');
            }

            // Remove sensitive data
            unset($user['password_hash']);

            return DatabaseUtils::formatResponse(true, 'Token is valid', [
                'user' => $user,
                'token_data' => $decoded
            ]);

        } catch (Exception $e) {
            return DatabaseUtils::formatResponse(false, 'Token validation failed: ' . $e->getMessage());
        }
    }

    /**
     * Refresh token
     */
    public function refreshToken($token) {
        try {
            $validation = $this->validateToken($token);
            
            if (!$validation['success']) {
                return $validation;
            }

            $user = $validation['data']['user'];
            
            // Generate new token
            $newToken = $this->generateJWT($user['id'], $user['email']);

            return DatabaseUtils::formatResponse(true, 'Token refreshed successfully', [
                'user' => $user,
                'token' => $newToken,
                'expires_in' => 86400
            ]);

        } catch (Exception $e) {
            return DatabaseUtils::formatResponse(false, 'Token refresh failed: ' . $e->getMessage());
        }
    }

    /**
     * Get user profile
     */
    public function getUserProfile($userId) {
        try {
            $user = $this->getUserById($userId);
            
            if (!$user) {
                return DatabaseUtils::formatResponse(false, 'User not found');
            }

            // Remove sensitive data
            unset($user['password_hash']);

            return DatabaseUtils::formatResponse(true, 'User profile retrieved successfully', [
                'user' => $user
            ]);

        } catch (Exception $e) {
            return DatabaseUtils::formatResponse(false, 'Failed to get user profile: ' . $e->getMessage());
        }
    }

    /**
     * Update user profile
     */
    public function updateProfile($userId, $updateData) {
        try {
            // Validate update data
            $allowedFields = ['first_name', 'last_name', 'phone', 'date_of_birth', 'gender'];
            $updateFields = [];
            $params = [':user_id' => $userId];

            foreach ($allowedFields as $field) {
                if (isset($updateData[$field]) && !empty($updateData[$field])) {
                    $updateFields[] = "$field = :$field";
                    $params[":$field"] = DatabaseUtils::sanitizeInput($updateData[$field]);
                }
            }

            if (empty($updateFields)) {
                return DatabaseUtils::formatResponse(false, 'No valid fields to update');
            }

            // Check if phone number is being updated and if it already exists
            if (isset($updateData['phone'])) {
                if (!DatabaseUtils::validatePhone($updateData['phone'])) {
                    return DatabaseUtils::formatResponse(false, 'Invalid phone number format');
                }
                
                $existingUser = $this->getUserByPhone($updateData['phone']);
                if ($existingUser && $existingUser['id'] != $userId) {
                    return DatabaseUtils::formatResponse(false, 'Phone number already exists');
                }
            }

            // Update user
            $sql = "UPDATE users SET " . implode(', ', $updateFields) . ", updated_at = NOW() WHERE id = :user_id";
            $this->db->query($sql, $params);

            // Get updated user data
            $user = $this->getUserById($userId);
            unset($user['password_hash']);

            return DatabaseUtils::formatResponse(true, 'Profile updated successfully', [
                'user' => $user
            ]);

        } catch (Exception $e) {
            return DatabaseUtils::formatResponse(false, 'Profile update failed: ' . $e->getMessage());
        }
    }

    /**
     * Change password
     */
    public function changePassword($userId, $currentPassword, $newPassword) {
        try {
            // Get user
            $user = $this->getUserById($userId);
            if (!$user) {
                return DatabaseUtils::formatResponse(false, 'User not found');
            }

            // Verify current password
            if (!DatabaseUtils::verifyPassword($currentPassword, $user['password_hash'])) {
                return DatabaseUtils::formatResponse(false, 'Current password is incorrect');
            }

            // Validate new password
            if (strlen($newPassword) < 8) {
                return DatabaseUtils::formatResponse(false, 'New password must be at least 8 characters long');
            }

            // Hash new password
            $hashedPassword = DatabaseUtils::hashPassword($newPassword);

            // Update password
            $sql = "UPDATE users SET password_hash = :password_hash, updated_at = NOW() WHERE id = :user_id";
            $this->db->query($sql, [
                ':password_hash' => $hashedPassword,
                ':user_id' => $userId
            ]);

            return DatabaseUtils::formatResponse(true, 'Password changed successfully');

        } catch (Exception $e) {
            return DatabaseUtils::formatResponse(false, 'Password change failed: ' . $e->getMessage());
        }
    }

    /**
     * Validate registration data
     */
    private function validateRegistrationData($data) {
        $errors = [];

        // Required fields
        $requiredFields = ['first_name', 'last_name', 'email', 'phone', 'password'];
        foreach ($requiredFields as $field) {
            if (empty($data[$field])) {
                $errors[] = ucfirst(str_replace('_', ' ', $field)) . ' is required';
            }
        }

        // Email validation
        if (!empty($data['email']) && !DatabaseUtils::validateEmail($data['email'])) {
            $errors[] = 'Invalid email format';
        }

        // Phone validation
        if (!empty($data['phone']) && !DatabaseUtils::validatePhone($data['phone'])) {
            $errors[] = 'Invalid phone number format';
        }

        // Password validation
        if (!empty($data['password'])) {
            if (strlen($data['password']) < 8) {
                $errors[] = 'Password must be at least 8 characters long';
            }
            if (!preg_match('/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/', $data['password'])) {
                $errors[] = 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
            }
        }

        // Name validation
        if (!empty($data['first_name']) && strlen($data['first_name']) < 2) {
            $errors[] = 'First name must be at least 2 characters long';
        }
        if (!empty($data['last_name']) && strlen($data['last_name']) < 2) {
            $errors[] = 'Last name must be at least 2 characters long';
        }

        return [
            'valid' => empty($errors),
            'errors' => $errors
        ];
    }

    /**
     * Check if user exists by email
     */
    private function userExists($email) {
        $sql = "SELECT id FROM users WHERE email = :email";
        $result = $this->db->single($sql, [':email' => $email]);
        return !empty($result);
    }

    /**
     * Check if phone exists
     */
    private function phoneExists($phone) {
        $sql = "SELECT id FROM users WHERE phone = :phone";
        $result = $this->db->single($sql, [':phone' => $phone]);
        return !empty($result);
    }

    /**
     * Get role by name
     */
    private function getRoleByName($roleName) {
        $sql = "SELECT * FROM user_roles WHERE name = :name AND is_active = 1";
        return $this->db->single($sql, [':name' => $roleName]);
    }

    /**
     * Get user by email
     */
    private function getUserByEmail($email) {
        $sql = "SELECT u.*, ur.name as role_name
                FROM users u
                JOIN user_roles ur ON u.role_id = ur.id
                WHERE u.email = :email";
        return $this->db->single($sql, [':email' => $email]);
    }

    /**
     * Get user by phone
     */
    private function getUserByPhone($phone) {
        $sql = "SELECT u.*, ur.name as role_name
                FROM users u
                JOIN user_roles ur ON u.role_id = ur.id
                WHERE u.phone = :phone";
        return $this->db->single($sql, [':phone' => $phone]);
    }

    /**
     * Get user by ID
     */
    private function getUserById($userId) {
        $sql = "SELECT u.*, ur.name as role_name
                FROM users u
                JOIN user_roles ur ON u.role_id = ur.id
                WHERE u.id = :user_id";
        return $this->db->single($sql, [':user_id' => $userId]);
    }

    /**
     * Update last login time
     */
    private function updateLastLogin($userId) {
        $sql = "UPDATE users SET last_login_at = NOW() WHERE id = :user_id";
        $this->db->query($sql, [':user_id' => $userId]);
    }

    /**
     * Generate JWT token
     */
    private function generateJWT($userId, $email, $expiresIn = 86400) {
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        $payload = json_encode([
            'user_id' => $userId,
            'email' => $email,
            'iat' => time(),
            'exp' => time() + $expiresIn
        ]);

        $base64Header = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64Payload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));

        $signature = hash_hmac('sha256', $base64Header . "." . $base64Payload, $this->jwtSecret, true);
        $base64Signature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

        return $base64Header . "." . $base64Payload . "." . $base64Signature;
    }

    /**
     * Decode JWT token
     */
    private function decodeJWT($token) {
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            return false;
        }

        $header = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $parts[0])), true);
        $payload = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $parts[1])), true);
        $signature = $parts[2];

        // Verify signature
        $expectedSignature = str_replace(['+', '/', '='], ['-', '_', ''],
            base64_encode(hash_hmac('sha256', $parts[0] . "." . $parts[1], $this->jwtSecret, true)));

        if ($signature !== $expectedSignature) {
            return false;
        }

        // Check expiration
        if ($payload['exp'] < time()) {
            return false;
        }

        return $payload;
    }
}
