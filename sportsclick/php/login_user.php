<?php
error_reporting(0);
include_once("dbconnect.php");
$email = $_POST['email'];
$password = sha1($_POST['password']);
$otp = $_POST['otp'];

$sqllogin = "SELECT * FROM USER WHERE EMAIL = '$email' AND PASSWORD = '$password' AND OTP = '0'";
$result = $conn->query($sqllogin);

$sqlload = "SELECT * FROM USER WHERE EMAIL = '$email' AND PASSWORD = '$password'";
$result2 = $conn->query($sqlload);

if ($result->num_rows > 0) { //>0 means found smtg
    while ($row = $result -> fetch_assoc()){
        //echo $data = $row["NAME"].",".$row["PHONE"];
        echo "success";
    }
}else{
    if ($result2->num_rows > 0) {
        echo "noverify";
    } else
        echo "failed";
}
?>