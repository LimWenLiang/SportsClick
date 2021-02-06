<?php
error_reporting(0);
include_once("dbconnect.php");

if (isset($_POST['posttitle'])) {
    $posttitle = $_POST['posttitle'];
    $sql = "SELECT DISTINCT POST.POSTID, POST.POSTTITLE, POST.POSTDESC, POST.POSTIMAGE, POST.POSTDATE, POST.USEREMAIL, USER.NAME FROM POST INNER JOIN USER ON POST.USEREMAIL = USER.EMAIL WHERE POST.POSTTITLE LIKE '%$posttitle%' ORDER BY POSTDATE";
} else {
    $sql = "SELECT POST.POSTID, POST.POSTTITLE, POST.POSTDESC, POST.POSTIMAGE, POST.POSTDATE, POST.USEREMAIL, USER.NAME FROM POST INNER JOIN USER ON POST.USEREMAIL = USER.EMAIL ORDER BY POSTDATE"; 
}

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
        $postlist[name] = $row["NAME"];
        array_push($response["post"], $postlist);
    }
    echo json_encode($response);
}else{
    echo "nodata";
}

?>