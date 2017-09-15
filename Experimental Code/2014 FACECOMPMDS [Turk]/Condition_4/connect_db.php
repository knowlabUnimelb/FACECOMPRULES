<?php
/* this script connects to the database specified on line 6 */

$db_host = "localhost"; // specify server name
$db_username = "tonyw"; // specify user name of MySQL database
$db_pass = "gup5B@ph"; // specify password
$db_name = "2014_facecomp_mds"; // specify database name

$dbc = mysql_connect($db_host, $db_username, $db_pass);
mysql_select_db($db_name, $dbc)

?>
 