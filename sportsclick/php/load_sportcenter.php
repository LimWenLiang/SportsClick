<?php
error_reporting(0);
include_once("dbconnect.php");

if (isset($_POST['centername'])) {
    $centername = $_POST['centername'];
    $sql = "SELECT DISTINCT ID, NAME, PHONE, LOCATION, OPENTIME, CLOSETIME, PRICE, OFFDAY, REMARKS, IMAGE FROM SPORTCENTER WHERE NAME LIKE '%$centername%' ORDER BY DATEREG";
} else {
    $sql = "SELECT * FROM SPORTCENTER ORDER BY DATEREG";
}

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $response["center"] = array();
    while ($row = $result ->fetch_assoc()) {
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
} else {
    echo "nodata";
}
?>