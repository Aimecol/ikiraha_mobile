<?php
/**
 * Database Configuration for Ikiraha Mobile Backend
 * Connects to the existing MySQL database created for the ordering system
 */

class Database {
    // Database configuration - matches your XAMPP setup
    private $host = 'localhost';
    private $database = 'ikiraha_ordering_system';
    private $username = 'root';
    private $password = '';
    private $charset = 'utf8mb4';
    
    private $pdo;
    private $error;

    /**
     * Database connection
     */
    public function __construct() {
        $dsn = "mysql:host={$this->host};dbname={$this->database};charset={$this->charset}";
        
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ];

        try {
            $this->pdo = new PDO($dsn, $this->username, $this->password, $options);
        } catch (PDOException $e) {
            $this->error = $e->getMessage();
            throw new Exception("Database connection failed: " . $this->error);
        }
    }

    /**
     * Get PDO instance
     */
    public function getConnection() {
        return $this->pdo;
    }

    /**
     * Execute a prepared statement
     */
    public function query($sql, $params = []) {
        try {
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            return $stmt;
        } catch (PDOException $e) {
            throw new Exception("Query execution failed: " . $e->getMessage());
        }
    }

    /**
     * Get single record
     */
    public function single($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->fetch();
    }

    /**
     * Get multiple records
     */
    public function resultSet($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->fetchAll();
    }

    /**
     * Get row count
     */
    public function rowCount($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->rowCount();
    }

    /**
     * Get last insert ID
     */
    public function lastInsertId() {
        return $this->pdo->lastInsertId();
    }

    /**
     * Begin transaction
     */
    public function beginTransaction() {
        return $this->pdo->beginTransaction();
    }

    /**
     * Commit transaction
     */
    public function commit() {
        return $this->pdo->commit();
    }

    /**
     * Rollback transaction
     */
    public function rollback() {
        return $this->pdo->rollback();
    }

    /**
     * Check if table exists
     */
    public function tableExists($tableName) {
        $sql = "SHOW TABLES LIKE ?";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$tableName]);
        $result = $stmt->fetch();
        return !empty($result);
    }

    /**
     * Test database connection
     */
    public function testConnection() {
        try {
            $this->pdo->query('SELECT 1');
            return [
                'success' => true,
                'message' => 'Database connection successful',
                'database' => $this->database,
                'host' => $this->host
            ];
        } catch (PDOException $e) {
            return [
                'success' => false,
                'message' => 'Database connection failed: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Get database info
     */
    public function getDatabaseInfo() {
        try {
            $version = $this->single("SELECT VERSION() as version");
            $tables = $this->resultSet("SHOW TABLES");
            
            return [
                'success' => true,
                'database' => $this->database,
                'version' => $version['version'],
                'tables_count' => count($tables),
                'tables' => array_column($tables, "Tables_in_{$this->database}")
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }
}

/**
 * Database utility functions
 */
class DatabaseUtils {
    
    /**
     * Generate UUID v4
     */
    public static function generateUUID() {
        return sprintf(
            '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
    }

    /**
     * Sanitize input
     */
    public static function sanitizeInput($input) {
        return htmlspecialchars(strip_tags(trim($input)));
    }

    /**
     * Validate email
     */
    public static function validateEmail($email) {
        return filter_var($email, FILTER_VALIDATE_EMAIL);
    }

    /**
     * Validate phone number
     */
    public static function validatePhone($phone) {
        // Remove all non-digit characters
        $phone = preg_replace('/[^0-9]/', '', $phone);
        // Check if it's between 10-15 digits
        return strlen($phone) >= 10 && strlen($phone) <= 15;
    }

    /**
     * Hash password
     */
    public static function hashPassword($password) {
        return password_hash($password, PASSWORD_DEFAULT);
    }

    /**
     * Verify password
     */
    public static function verifyPassword($password, $hash) {
        return password_verify($password, $hash);
    }

    /**
     * Generate random token
     */
    public static function generateToken($length = 32) {
        return bin2hex(random_bytes($length));
    }

    /**
     * Format response
     */
    public static function formatResponse($success, $message, $data = null, $errors = null) {
        $response = [
            'success' => $success,
            'message' => $message,
            'timestamp' => date('Y-m-d H:i:s')
        ];

        if ($data !== null) {
            $response['data'] = $data;
        }

        if ($errors !== null) {
            $response['errors'] = $errors;
        }

        return $response;
    }
}
?>
