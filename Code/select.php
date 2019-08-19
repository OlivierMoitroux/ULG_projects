<meta charset="utf-8" />
<?php

include("security.php");

include("db_connect.php");

include("display_query.php");

$cond = "1=1";
foreach (array_keys($_POST) as $field) {

	if ($field != "table" && !empty($_POST[$field])) {

		if(intval($_POST[$field]) != 0){
			// Si input est un nombre -> égalité stricte
			$cond = $cond . " AND " . $field . "='" . $_POST[$field] . "'";
		}
		else{
			// Si input est un string -> contenance
			$cond = $cond . " AND " . $field . " LIKE '%" . $_POST[$field] . "%'";
		}
    }
}

$req="SELECT * FROM " . $_POST['table'] . " WHERE " . $cond;
display_query($req);

?>
