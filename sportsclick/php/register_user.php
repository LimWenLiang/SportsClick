<?php
include_once("dbconnect.php"); // connect to dbconnect.php
// post/get array which can received value from any API (post array more secure)
$name = $_POST['name'];
$email = $_POST['email'];
$phone = $_POST['phone'];
$password = sha1($_POST['password']); // encryted the value
$otp = rand(1000, 9999);
$passwordotp = rand(1000, 9999);

//build php string
$sqlregister = "INSERT INTO USER(NAME, EMAIL, PHONE, PASSWORD, OTP, PASSWORDOTP) VALUES('$name', '$email', '$phone', '$password', '$otp', '$passwordotp')";

if ($conn->query($sqlregister) === TRUE){
    sendEmail($otp, $passwordotp, $email);
    echo "success";
}else{
    echo "failed";
}

function sendEmail($otp, $passwordotp, $email){
    $from = "noreply@sportsclick.com";
    $to = $email;
    $subject = "From SportsClick. Verify your account.";
    $message = "Use the following link to verify your account:"."\n http://itprojectoverload.com/sportsclick/php/verify_account.php?email=".$email."&key1=".$otp."&key2=".$passwordotp;
    $headers = "From:" . $from;
    mail($email, $subject, $message, $headers);
}
?>