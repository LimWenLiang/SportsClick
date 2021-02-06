<?php
$servername = "localhost";
$username = "itprojec_sportsclickadmin";
$password = "rmp}J5c1(kk[";
$dbname = "itprojec_sportsclick";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>