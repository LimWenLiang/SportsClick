<?php
error_reporting(0);
include_once("dbconnect.php");

$useremail = $_POST['useremail'];
$postid = $_POST['postid'];
    $sqldelete = "DELETE FROM POST WHERE USEREMAIL = '$useremail' AND POSTID='$postid'";
    if ($conn->query($sqldelete) === TRUE){
       echo "success";
    }else {
        echo "failed";
    }
?>