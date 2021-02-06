<?php
error_reporting(0);
include_once("dbconnect.php");
$email = $_POST['email'];
$otp = '0';
$passwordotp = rand(1000, 9999);

$sqlverify = "SELECT * FROM USER WHERE EMAIL = '$email'";
$result = $conn->query($sqlverify);

if ($result->num_rows > 0) {
    $sqlupdate = "UPDATE USER SET PASSWORDOTP = '$passwordotp' WHERE EMAIL = '$email'";
    if ($conn->query($sqlupdate) === TRUE){
        sendEmail($otp, $passwordotp, $email);
        echo 'success';
    }else{
        echo 'failed';
    } 
}else{
    echo "failed";
}

function sendEmail($otp, $passwordotp, $email){
    $from = "noreply@sportsclick.com";
    $to = $email;
    $subject = "From SportsClick. Verify your account.";
    $message = "Use the following link to verify your account:"."\n http://itprojectoverload.com/sportsclick/php/verify_account.php?email=".$email."&otp=".$otp."&passwordotp=".$passwordotp;
    $headers = "From:" . $from;
    mail($email, $subject, $message, $headers);
}
?>