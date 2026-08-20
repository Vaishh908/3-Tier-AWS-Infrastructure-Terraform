<?php
$host = getenv('DB_HOST');
$user = getenv('DB_USER');
$pass = getenv('DB_PASSWORD');
$db   = getenv('DB_NAME');

if (!$host || !$user || !$db) {
    http_response_code(500);
    die("Database configuration is missing.");
}

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    http_response_code(500);
    die("Database connection failed.");
}

$name  = $_POST['name'] ?? '';
$email = $_POST['email'] ?? '';
$phone = $_POST['phone'] ?? '';

$stmt = $conn->prepare(
    "INSERT INTO registrations (name, email, phone) VALUES (?, ?, ?)"
);
$stmt->bind_param("sss", $name, $email, $phone);

if ($stmt->execute()) {
    echo "<!DOCTYPE html><html><head><title>Registration Successful</title></head>";
    echo "<body><h1>Registration Successful</h1>";
    echo "<p>Thank you, " . htmlspecialchars($name) . ".</p>";
    echo "<p>Your registration has been stored in the database.</p></body></html>";
} else {
    http_response_code(500);
    echo "Unable to store registration.";
}

$stmt->close();
$conn->close();
?>
