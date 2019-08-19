<?php include("security.php");?>

<html>
    <meta charset="utf-8" />
    <head>
        <title> Projet 2 Base de données </title>
    </head>

    <link rel="stylesheet" type="text/css" href="style.css"/>
    <body>

        <?php
        $page = "c";
        include("menu.php");
        include('display_query.php');

        $query = "SELECT * FROM Personnel WHERE n_registre IN
                    (SELECT n_registre FROM Entretien
                     GROUP BY n_registre
                     HAVING COUNT(DISTINCT n_enclos)=(SELECT COUNT(*) FROM Enclos))";

        ?>

        <div class = "Main_field">
            <h2>Question 2.c</h2>
            <p>"Retrouvez les techniciens qui ont travaillé dans l'ensemble des enclos du parc animalier."</p>
            <?php display_query($query); ?>
        </div>
    </body>
    </html>
