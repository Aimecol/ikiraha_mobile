<?php
// Simple Backend Connection Test
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    // Database configuration
    $host = 'localhost';
    $database = 'ikiraha_ordering_system';
    $username = 'root';
    $password = '';
    
    // Create PDO connection
    $dsn = "mysql:host=$host;dbname=$database;charset=utf8mb4";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    
    // Test query
    $stmt = $pdo->query("SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = '$database'");
    $result = $stmt->fetch();
    
    // Get MySQL version
    $version = $pdo->query("SELECT VERSION() as version")->fetch();
    
    echo json_encode([
        'success' => true,
        'message' => 'Database connection successful',
        'database' => $database,
        'host' => $host,
        'mysql_version' => $version['version'],
        'tables_count' => $result['table_count'],
        'php_version' => phpversion(),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_PRETTY_PRINT);
    
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Database connection failed',
        'error' => $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_PRETTY_PRINT);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'General error',
        'error' => $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_PRETTY_PRINT);
}
?>
