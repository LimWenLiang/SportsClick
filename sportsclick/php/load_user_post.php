<?php
error_reporting(0);
include_once("dbconnect.php");

$useremail = $_POST['useremail'];

$sql = "SELECT * FROM POST WHERE USEREMAIL = '$useremail'"; 
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $response["post"] = array();
    while ($row = $result ->fetch_assoc()){
        $postlist = array();
        $postlist[postid] = $row["POSTID"];
        $postlist[posttitle] = $row["POSTTITLE"];
        $postlist[postdesc] = $row["POSTDESC"];
        $postlist[postimage] = $row["POSTIMAGE"];
        $postlist[postdate] = $row["POSTDATE"];
        $postlist[useremail] = $row["USEREMAIL"];
        array_push($response["post"], $postlist);
    }
    echo json_encode($response);
}else{
    echo "nodata";
}
?>