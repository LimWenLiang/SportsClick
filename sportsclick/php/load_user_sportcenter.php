<?php
error_reporting(0);
include_once("dbconnect.php");

$useremail = $_POST['useremail'];

$sql = "SELECT * FROM SPORTCENTER WHERE USEREMAIL = '$useremail'"; 
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $response["center"] = array();
    while ($row = $result ->fetch_assoc()){
        $centerlist = array();
        $centerlist[centerid] = $row["ID"];
        $centerlist[centername] = $row["NAME"];
        $centerlist[centerphone] = $row["PHONE"];
        $centerlist[centerlocation] = $row["LOCATION"];
        $centerlist[centeropentime] = $row["OPENTIME"];
        $centerlist[centerclosetime] = $row["CLOSETIME"];
        $centerlist[centerprice] = $row["PRICE"];
        $centerlist[centeroffday] = $row["OFFDAY"];
        $centerlist[centerremarks] = $row["REMARKS"];
        $centerlist[centerimage] = $row["IMAGE"];
        array_push($response["center"], $centerlist);
    }
    echo json_encode($response);
}else{
    echo "nodata";
}
?>