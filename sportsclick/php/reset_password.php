<?php
error_reporting(0);
include_once("dbconnect.php");
$email = $_POST['email'];
$password = sha1($_POST['password']);

$sqlreset = "SELECT * FROM USER WHERE EMAIL = '$email' AND PASSWORDOTP = '0'";
$result = $conn->query($sqlreset);

if ($result->num_rows > 0) {
    $sqlupdate = "UPDATE USER SET PASSWORD = '$password', PASSWORDOTP = '0' WHERE EMAIL = '$email'";
    if ($conn->query($sqlupdate) === TRUE){
        echo 'success';
    }else{
        echo 'failed';
    } 
}else{
    echo "noverify";
}
?>