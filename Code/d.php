<?php include("security.php");?>

<html>
    <meta charset="utf-8" />
    <head>
        <title> Projet 2 Base de données </title>
    </head>

    <link rel="stylesheet" type="text/css" href="style.css"/>


    <body>

        <?php
            $page = "d";
            include("menu.php");
            include('display_query.php');
            $query = "SELECT COUNT(*) * 1.0 / (SELECT COUNT(*) FROM Intervention) AS Proportion FROM Intervention i WHERE EXISTS (SELECT * FROM (SELECT * FROM (SELECT nom_scientifique, n_puce, n_enclos FROM Animal) AS an NATURAL JOIN (SELECT n_enclos, climat FROM Enclos) AS encl) c WHERE climat NOT IN (SELECT nom_climat FROM Climat WHERE nom_scientifique=c.nom_scientifique) AND nom_scientifique=i.nom_scientifique AND n_puce=i.n_puce)";
        ?>

        <div class = "Main_field">
            <h2>Question 2.d</h2>
            <p>"Retrouver la proportion d'interventions qui ont été effectuées sur les annimaux présents dans un enclos dont le climat ne correspond pas à l'un de ceux supportés par son espèce."</p>
            <?php display_query($query); ?>
        </div>

    </body>
    </html>
