<?php
include_once("dbconnect.php");

$postid = $_POST['postid'];
$posttitle = $_POST['posttitle'];
$postdesc = $_POST['postdesc'];
$postimage = $_POST['postimage'];
$useremail = $_POST['useremail'];
$encoded_string = $_POST["encoded_string"];

$decoded_string = base64_decode($encoded_string);
$path = '../images/postimages/'.$postimage.'.jpg';
$is_written = file_put_contents($path, $decoded_string);

$sqlregister = "UPDATE POST SET POSTTITLE = '$posttitle', POSTDESC = '$postdesc', POSTIMAGE = IF(LENGTH('$postimage')=0, POSTIMAGE, '$postimage') WHERE POSTID = '$postid' AND USEREMAIL = '$useremail'";

if ($conn->query($sqlregister) === TRUE){
    echo "success";
}else{
    echo "failed";
}
?>
