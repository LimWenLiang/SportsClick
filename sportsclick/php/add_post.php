<?php
include_once("dbconnect.php");

$posttitle = $_POST['posttitle'];
$postdesc = $_POST['postdesc'];
$postimage = $_POST['postimage'];
$useremail = $_POST['useremail'];
$encoded_string = $_POST["encoded_string"];

$decoded_string = base64_decode($encoded_string);
$path = '../images/postimages/'.$postimage.'.jpg';
$is_written = file_put_contents($path, $decoded_string);

if ($is_written > 0) {
    $sqlregister = "INSERT INTO POST(POSTTITLE, POSTDESC, POSTIMAGE, USEREMAIL) VALUES('$posttitle','$postdesc','$postimage','$useremail')";
    if ($conn->query($sqlregister) === TRUE){
        echo "success";
    }else{
        echo "failed";
    }
}else{
    echo "failed";
}

?>