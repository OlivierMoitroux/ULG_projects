<?php include("security.php");?>

<html>
    <meta charset="utf-8" />
    <head>
        <title> Projet 2 Base de données </title>
    </head>

    <link rel="stylesheet" type="text/css" href="style.css"/>
    <body>

        <?php
            $page = "b";
            include("menu.php");
            include('display_query.php');

            // Query for the database
            $query = "SELECT * FROM Animal
                        NATURAL JOIN
                        (SELECT nom_scientifique, n_puce, COUNT( DISTINCT n_registre) AS n_vete_intervenus
                            FROM Intervention GROUP BY nom_scientifique, n_puce)AS whathever ORDER BY n_vete_intervenus";
            ?>
            <div class = "Main_field">

                <h2>Question 2.b</h2>
                <p>"Trier les annimaux du parc par le nombre de vétérinaires différents qui sont intervenus au moins une fois sur eux."</p>

           <?php
                display_query($query);
             ?>
             </div>
    </body>
    </html>
