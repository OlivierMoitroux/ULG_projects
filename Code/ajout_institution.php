<meta charset="utf-8" />
<?php
include("security.php");
include("db_connect.php");

$nom_institution = $_POST['nom_institution'];
$rue = $_POST['rue'];
$code_postal = $_POST['code_postal'];
$pays = $_POST['pays'];

$nom_scientifique = $_POST['nom_scientifique'];
$n_puce = $_POST['n_puce'];
$taille = $_POST['taille'];
$sexe = $_POST['sexe'];
$date_naissance = $_POST['date_naissance'];
$n_enclos = $_POST['n_enclos'];


$request = 'INSERT INTO Institution (nom_institution, rue, code_postal, pays)VALUES("'. $nom_institution .'","'. $rue .'","'. $code_postal .'", "'. $pays .'")';
$result = $dbc->query($request);

if($result) {
    echo "L'institution ".$nom_institution." a bien été ajoutée dans la table <br>";
    include("db_connect.php");
    mysqli_autocommit($dbc,FALSE);

    $request = 'INSERT INTO Animal (nom_scientifique, n_puce, taille, sexe, date_naissance, n_enclos) VALUES("'. $nom_scientifique .'", '. $n_puce .','. $taille .',"'. $sexe .'", "'. $date_naissance .'",'. $n_enclos.')';
    $result = $dbc->query($request);

    if($result == false){

        echo "Echec de l'ajout de l'animal: <br>";
        echo $dbc->error;
        header( 'Refresh:5;url=e.php');
    }
    else {

        $request= 'INSERT INTO Provenance (nom_scientifique, n_puce, nom_institution)VALUES("'. $nom_scientifique .'",'. $n_puce .',"'. $nom_institution .'")';
        if($dbc->query($request) == false){
            echo "Echec de l'ajout dans la table provenance <br>";
            echo $dbc->error;
            header( 'Refresh:5;url=e.php');
        }
        else {
            header( 'Refresh:4;url=e.php');
            mysqli_commit($dbc);
            echo "<br>L'animal a bien été ajouté à la base de donnée<br>";
        }

    }

}
else{
    header( 'Refresh:4;url=e.php');
    echo 'Cette institution existe déjà<br>';
}
mysqli_close($dbc);

?>
