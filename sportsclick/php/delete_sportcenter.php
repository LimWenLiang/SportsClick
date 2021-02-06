<?php
error_reporting(0);
include_once("dbconnect.php");

$useremail = $_POST['useremail'];
$centerid = $_POST['centerid'];
    $sqldelete = "DELETE FROM SPORTCENTER WHERE USEREMAIL = '$useremail' AND ID='$centerid'";
    if ($conn->query($sqldelete) === TRUE){
       echo "success";
    }else {
        echo "failed";
    }
?>