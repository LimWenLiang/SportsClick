<?php
include_once("dbconnect.php");

$centerid = $_POST['centerid'];
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

$sql = "UPDATE SPORTCENTER SET NAME = '$centername', PHONE = '$centerphone', LOCATION = '$centerlocation', OPENTIME = '$centeropentime', CLOSETIME = '$centerclosetime', PRICE = '$centerprice', OFFDAY = '$centeroffday', REMARKS = '$centerremarks', IMAGE = IF(LENGTH('$centerimage')=0, IMAGE, '$centerimage') WHERE ID = '$centerid' AND USEREMAIL = '$useremail'";

if ($conn->query($sql) === TRUE){
    echo "success";
}else{
    echo "failed";
}
?>
