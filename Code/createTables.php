
<meta charset="utf-8" />

<?php

	function loadTable($nom)
	{
		include('db_connect.php');
		$request = "LOAD DATA LOCAL INFILE 'db2018/" . $nom . ".txt'
							IGNORE INTO TABLE " . $nom ." FIELDS TERMINATED BY ','
							LINES TERMINATED BY '\n' IGNORE 1 LINES";


		$isLoaded = $dbc->query($request); // mysqli_query();

		if($isLoaded)
			echo "la table " . $nom . " a été correctement initialisée <br />";
		else
			echo "la table " . $nom . " n'a pas été initialisée: ". $dbc->error ."<br />";

	}

	include('db_connect.php');

	/*
	 * Création de la table Institution
	 */
	$tableBuilt = $dbc->query(" CREATE table IF NOT EXISTS Institution  (
                                nom_institution VARCHAR(50) NOT NULL,
                                rue VARCHAR(50) NOT NULL,
                                code_postal INTEGER NOT NULL,
                                pays VARCHAR(50) NOT NULL,
                                PRIMARY KEY(nom_institution)
                                ) ENGINE=INNODB");

	if($tableBuilt) {
		loadTable("Institution");
	}
	else {echo 'Table Institution creation failed<br>';}

    /*
	 * Création de la table Espece
	 */
	$tableBuilt = $dbc->query("CREATE table IF NOT EXISTS Espece (
                                nom_scientifique VARCHAR(50) NOT NULL,
                                nom_courant VARCHAR(50) NOT NULL,
                                regime_alimentaire VARCHAR(50) NOT NULL,
                                PRIMARY KEY(nom_scientifique)
                                )ENGINE=INNODB");

	if($tableBuilt) {
		loadTable("Espece");
	}
	else {
		echo 'Table Espece creation failed<br>';
	}

    /*
	 * Création de la table Climat
	 */
	$tableBuilt = $dbc->query("CREATE table IF NOT EXISTS Climat(
                                nom_scientifique VARCHAR(50) NOT NULL,
                                nom_climat VARCHAR(50) NOT NULL,
                                FOREIGN KEY(nom_scientifique) REFERENCES Espece(nom_scientifique),
								PRIMARY KEY(nom_scientifique, nom_climat)
                                )ENGINE=INNODB");

	if($tableBuilt) {
		loadTable("Climat");
	}
	else {echo 'Table Climat creation failed<br>';}

    /*
	 * Création de la table Animal
	 */
	$tableBuilt = $dbc->query("CREATE table IF NOT EXISTS Animal(
                                nom_scientifique VARCHAR(50) NOT NULL,
                                n_puce INTEGER NOT NULL,
                                taille VARCHAR(50) NOT NULL,
                                sexe VARCHAR(1) NOT NULL,
                                date_naissance VARCHAR(50) NOT NULL,
                                n_enclos INTEGER NOT NULL,
                                FOREIGN KEY(nom_scientifique) REFERENCES Espece(nom_scientifique),
								PRIMARY KEY (nom_scientifique, n_puce)
                                )ENGINE=INNODB");

	if($tableBuilt) {
		loadTable("Animal");
	}
	else {echo 'Table Animal creation failed<br>';}

    /*
	 * Création de la table Enclos
	 */
	$tableBuilt = $dbc->query("CREATE table IF NOT EXISTS Enclos(
                                n_enclos INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
                                climat VARCHAR(50) NOT NULL,
                                taille VARCHAR(50)
                                )ENGINE=INNODB");

	if($tableBuilt) {
		loadTable("Enclos");
	}
	else {echo 'Table Enclos creation failed<br>';}


    /*
	 * Création de la table Materiel
	 */
	$tableBuilt = $dbc->query("CREATE table IF NOT EXISTS Materiel(
                                n_materiel INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
                                etat VARCHAR(50) NOT NULL,
                                local VARCHAR(50) NOT NULL
                                )ENGINE=INNODB");

	if($tableBuilt) {
		loadTable("Materiel");
	}
	else {echo 'Table Materiel creation failed<br>';}

    /*
	 * Création de la table Personnel
	 */
	$tableBuilt = $dbc->query("CREATE table IF NOT EXISTS Personnel(
                                n_registre INTEGER PRIMARY KEY NOT NULL,
                                nom VARCHAR(50) NOT NULL,
                                prenom VARCHAR(50) NOT NULL
                                )ENGINE=INNODB");

	if($tableBuilt) {
		loadTable("Personnel");
	}
	else {echo 'Table Personnel creation failed<br>';}

    /*
	 * Création de la table Veterinaire
	 */
	$tableBuilt = $dbc->query("CREATE table IF NOT EXISTS Veterinaire(
                                n_registre INTEGER PRIMARY KEY NOT NULL,
                                n_license BIGINT NOT NULL,
                                specialite VARCHAR(50) NOT NULL,
                                FOREIGN KEY (n_registre) REFERENCES Personnel(n_registre)
                                )ENGINE=INNODB");

	if($tableBuilt) {
		loadTable("Veterinaire");
	}
	else {echo 'Table Veterinaire creation failed<br>';}

    /*
	 * Création de la table Technicien
	 */
	$tableBuilt = $dbc->query("CREATE table IF NOT EXISTS Technicien(
                                n_registre INTEGER PRIMARY KEY NOT NULL,
                                FOREIGN KEY (n_registre) REFERENCES Personnel(n_registre)
                                )ENGINE=INNODB");

	if($tableBuilt) {
		loadTable("Technicien");
	}
	else {echo 'Table Technicien creation failed<br>';}

    /*
	 * Création de la table Intervention
	 */
	$tableBuilt = $dbc->query("CREATE table IF NOT EXISTS Intervention(
                                n_intervention INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
                                date VARCHAR(50) NOT NULL,
                                description TEXT,
                                n_registre INTEGER NOT NULL,
                                nom_scientifique VARCHAR(50) NOT NULL,
                                n_puce INTEGER NOT NULL
                                )ENGINE=INNODB");

	if($tableBuilt) {
		loadTable("Intervention");
	}
	else {echo 'Table Intervention creation failed<br>';}

    /*
	 * Création de la table Entretien
	 */
	$tableBuilt = $dbc->query("CREATE table IF NOT EXISTS Entretien(
                                n_entretien INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL,
                                n_registre INTEGER NOT NULL,
                                n_materiel INTEGER NOT NULL,
                                date VARCHAR(50) NOT NULL,
                                n_enclos INTEGER NOT NULL
                                )ENGINE=INNODB");

	if($tableBuilt) {
		loadTable("Entretien");
	}
	else {echo 'Table Entretien creation failed<br>';}

    /*
	 * Création de la table Provenance
	 */
	$tableBuilt = $dbc->query("CREATE table IF NOT EXISTS Provenance (
                                nom_scientifique VARCHAR(50) NOT NULL,
                                n_puce INTEGER NOT NULL,
                                nom_institution VARCHAR(50) NOT NULL,
								FOREIGN KEY (nom_scientifique, n_puce) REFERENCES Animal (nom_scientifique, n_puce),
                                FOREIGN KEY (nom_institution) REFERENCES Institution(nom_institution),
								PRIMARY KEY(nom_scientifique, n_puce)
							)ENGINE=INNODB;");
	if($tableBuilt) {
		loadTable("Provenance");
	}
	else {echo 'Table Provenance creation failed<br>';}

    /*
    * Déconnexion del la db
    */
	mysqli_close($dbc);
?>
