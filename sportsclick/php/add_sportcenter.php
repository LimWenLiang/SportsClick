<?php
include_once("dbconnect.php");

$centername = $_POST['centername'];
$centerphone = $_POST['centerphone'];
$centerlocation = $_POST['centerlocation'];
$centeropentime = $_POST['centeropentime'];
$centerclosetime = $_POST['centerclosetime'];
$centerprice = $_POST['centerprice'];
$centeroffday = $_POST['centeroffday'];
$centerremarks = $_POST['centerremarks'];
$centerimage = $_POST['centerimage'];
$useremail = $_POST['useremail'];
$encoded_string = $_POST["encoded_string"];

$decoded_string = base64_decode($encoded_string);
$path = '../images/sportcenterimages/'.$centerimage.'.jpg';
$is_written = file_put_contents($path, $decoded_string);

if ($is_written > 0) {
    $sqlregister = "INSERT INTO SPORTCENTER(NAME, PHONE, LOCATION, OPENTIME, CLOSETIME, PRICE, OFFDAY, REMARKS, IMAGE, USEREMAIL) VALUES('$centername', '$centerphone', '$centerlocation', '$centeropentime', '$centerclosetime', '$centerprice', '$centeroffday', '$centerremarks', '$centerimage', '$useremail')";
    if ($conn->query($sqlregister) === TRUE){
        echo "success";
    }else{
        echo "failed";
    }
}else{
    echo "failed";
}

?>