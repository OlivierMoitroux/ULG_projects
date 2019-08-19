<meta charset="utf-8" />
<?php
    include("db_connect.php");

	function dropTable($tableName)
	{
        include("db_connect.php");
		$request = "DROP TABLE " . $tableName;
		$isDeleted = $dbc->query($request);
		if($isDeleted)
			echo "La table " . $tableName . " a été suprimée <br />";
		else
			echo "La table " . $tableName . " n'a pas été suprimée <br />";
	}

	dropTable("Climat");
	dropTable("Enclos");
	dropTable("Entretien");
	dropTable("Intervention");
	dropTable("Materiel");
	dropTable("Provenance");
    dropTable("Technicien");
	dropTable("Veterinaire");
    dropTable("Personnel");
    dropTable("Institution");
    dropTable("Animal");
    dropTable("Espece");

	mysqli_close($dbc);
    $_SESSION['loggedIn'] = false;
    session_destroy();
    // header('Location: index.html');
?>
