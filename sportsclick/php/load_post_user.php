<?php
error_reporting(0);
include_once("dbconnect.php");

$email = $_POST['email'];

$sql = "SELECT POST.USEREMAIL, USER.NAME FROM POST INNER JOIN USER ON POST.USEREMAIL = USER.EMAIL"; 
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $response["postuser"] = array();
    while ($row = $result ->fetch_assoc()){
        $userlist = array();
        $userlist[useremail] = $row["USEREMAIL"];
        $userlist[name] = $row["NAME"];
        array_push($response["postuser"], $userlist);
    }
    echo json_encode($response);
}else{
    echo "nodata";
}
?>