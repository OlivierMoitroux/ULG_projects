<html>
<link rel="stylesheet" type="text/css" href="style.css"/>
<meta charset="utf-8"/>
<?php

function display_query($query) {

    if(!isset($query))
        exit();

    include('db_connect.php');

    // Get data from database
    $result = @mysqli_query($dbc, $query);

    // If the query executed properly proceed
    if ($result) {

        echo '<table class=query_result>';
        echo '<tr>';
    	while ($property = mysqli_fetch_field($result)) {
    	    echo '<th align="left"><b>' . $property->name . '</b></th>';
    	}
        echo '</tr>';

        // mysqli_fetch_array will return a row of data from the query
        // until no further data is available
        while ($row = mysqli_fetch_array($result, MYSQLI_NUM)) {
            echo '<tr>';
    		for ($i = 0; $i < $result->field_count; $i++) {
                		echo '<td align="left">' . $row[$i] . '</td>';
    		}
            echo '</tr>';
        }
        echo '</table>';
        $result->free();

    }
    else {
        echo "<p>Impossible d'effectuer la requête mysql : ". mysqli_error($dbc) ."</p><br />";
    }

    // Close connection to the database
    mysqli_close($dbc);
}
?>
</html>
