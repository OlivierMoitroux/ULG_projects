<meta charset="utf-8" />
<?php
include("security.php");

$nom_scientifique = $_POST['nom_scientifique'];
$n_puce = $_POST['n_puce'];
$taille = $_POST['taille'];
$sexe = $_POST['sexe'];
$date_naissance = $_POST['date_naissance'];

$n_enclos = $_POST['n_enclos'];
$nom_institution = $_POST['nom_institution'];

if(!animalNotYetInDB($n_puce, $nom_scientifique)) {
    header('Refresh:4;url=e.php');
    echo "Cet animal est déjà présent dans la base de donnée<br>";
}
else{
    include("db_connect.php");

    if(!rightEnclos($nom_scientifique, $n_enclos)) {
        echo "Attention, cet animal n'est pas dans un enclos adapté à son climat naturel<br>";
    }

    if($nom_institution == "Autres") {
        echo'
        <html>
        <link rel="stylesheet" type="text/css" href="style.css"/>
        <body>
        <div>
            <form method="post" action="ajout_institution.php">
                <fieldset >
                        <legend>Nouvelle institution</legend>

                        <label><span>Nom de l\'institution:  </span> <br><input type="text" name="nom_institution" size="30" maxlength="50" required> </label> <br />
                        <label><span>Rue:  </span><br> <input type="text" name="rue" size="30" maxlength="100" required> </label> <br />
                        <label><span>Code postal:  </span> <br><input type="number" name="code_postal" min="1" max ="2147483647" required ></label> <br />
                        <label><span>Pays:  </span><br> <input type="text" name="pays" size="30" maxlength="50" required> </label> <br />
                        <input type="hidden" name="nom_scientifique" value="'.$nom_scientifique.'">
                        <input type="hidden" name="nom_climat" value="'.$nom_climat.'">
                        <input type="hidden" name="n_puce" value="'.$n_puce.'">
                        <input type="hidden" name="taille" value="'.$taille.'">
                        <input type="hidden" name="sexe" value="'.$sexe.'">
                        <input type="hidden" name="date_naissance" value="'.$date_naissance.'">
                        <input type="hidden" name="n_enclos" value="'.$n_enclos.'">
                    <br>
                    <input type="submit" value="Ajouter" class="Small_submit"/>
                </fieldset><br />
            </form>
        </div>
        </body>
        </html>
        ';

    }
    else{

        $request = 'INSERT INTO Animal (nom_scientifique, n_puce, taille, sexe, date_naissance, n_enclos)VALUES("'. $nom_scientifique .'", '. $n_puce .','. $taille .',"'. $sexe .'", "'. $date_naissance .'",'. $n_enclos.')';
        $result = $dbc->query($request);

        if($result) {

            if($nom_institution != "vide"){
                include("db_connect.php");
                $request = 'INSERT INTO Provenance (nom_scientifique, n_puce, nom_institution)VALUES("'. $nom_scientifique .'",'. $n_puce .',"'. $nom_institution .'")';
                $result = $dbc->query($request);

                if(!$result) {
                    //header( 'Refresh:5;url=e.php');
                    echo "Impossible de mettre à jour la table provenance:<br>";
                    echo $dbc->error;
                }
                else{

                    header( 'Refresh:4;url=e.php');
                    echo "Succès de l'ajout dans les tables Animal et Provenance<br>";
                }
            }
            else{

                header( 'Refresh:4;url=e.php');
                echo "Succès de l'ajout dans la table<br>";
            }
        }
        else{
            header( 'Refresh:5;url=e.php');
            echo "L'ajout de l'animal a échoué: <br>";
            echo $dbc->error;
        }
        mysqli_close($dbc);
    }
}



function convertDate($dateEN) {
    $time = strtotime($dateEN);
    $newformat = date('d/m/Y',$time);

    return $newformat;
}

function animalNotYetInDB($n_puce, $nom_scientifique) {

    include("db_connect.php");
    $request = 'SELECT * from Animal WHERE nom_scientifique = "'. $nom_scientifique . '" AND n_puce = ' . $n_puce;
    $result = $dbc->query($request);

    if($result) {
        $row = mysqli_fetch_array($result);

        if ($row[0] == null) {
            return true;
        }
        return false;
    }
    return false;
}

function rightEnclos($nom_scientifique, $n_enclos) {
    include("db_connect.php");
    $request = 'SELECT climat FROM Enclos WHERE n_enclos =' . $n_enclos;

    $climats_enclos_table = $dbc->query($request);

    if($climats_enclos_table){

        $request1 = 'SELECT nom_climat from Climat WHERE nom_scientifique = "'. $nom_scientifique.'"';
        $climats_espece_table = $dbc->query($request1);

        if ($climats_espece_table) {

            while($climat_enclos_row = mysqli_fetch_array($climats_enclos_table, MYSQLI_NUM)){
                while ($climat_espece_row = mysqli_fetch_array($climats_espece_table, MYSQLI_NUM)) {
                    if($climat_enclos_row[0] == $climat_espece_row[0]){
                        return true;
                    }
                }
            }
            // mauvais climat
            return false;
        }
        // erreur
        echo 'erreur';
        return true;
    }
    // erreur
    echo 'erreur 2';
    return true;
}

?>
