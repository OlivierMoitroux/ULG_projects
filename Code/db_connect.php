<meta charset="utf-8" />
<?php

$DB_USER='group6';
$DB_PASSWORD='LB//N/1vMJ';
$DB_HOST='ms800';
$DB_NAME='group6';

$dbc = @mysqli_connect($DB_HOST, $DB_USER, $DB_PASSWORD, $DB_NAME);

/* check connection */
if ($dbc->connect_errno) {
    printf("Connection failed: %s\n", $dbc->connect_error);

    exit();
}

?>
