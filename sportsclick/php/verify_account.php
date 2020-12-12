<?php
    error_reporting(0);
    include_once("dbconnect.php");
    $email = $_GET['email'];
    $otp = $_GET['key1'];
    $passwordotp = $_GET['key2'];
    
    $sqllogin = "SELECT * FROM USER WHERE EMAIL = '$email' AND OTP = '$otp' AND PASSWORDOTP = '$passwordotp'";
    $resultlogin = $conn->query($sqllogin);
    
    if ($resultlogin->num_rows > 0) {
        $sqlupdate = "UPDATE USER SET OTP = '0', PASSWORDOTP = '0' WHERE EMAIL = '$email'";
        if ($conn->query($sqlupdate) === TRUE){
            echo 'success';
        }else{
            echo 'failed';
        }   
    }else{
        echo "failed";
    }
?>