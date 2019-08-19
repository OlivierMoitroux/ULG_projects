<?php include("security.php"); ?>

<html>
    <meta charset="utf-8"/>
    <head>
        <title> Projet 2 Base de données </title>
    </head>

    <link rel="stylesheet" type="text/css" href="style.css"/>

    <body>

        <?php
        $page = "e";
        include("menu.php");
        include("db_connect.php");
        ?>

        <div class = "Main_field">
            <h2>Question 2.e</h2>
            <p>"Ajout d'un animal dans la base de données."</p>

            <div class="ajout_animal_form">
                    <form method="post" action="ajout_animal.php"> <!-- ajout_animal.php -->
                        <fieldset >
                                <legend>Animal</legend>
                                <label><span>Nom scientifique:  </span> <br>
                                    <select id="nom_scientifique" name="nom_scientifique">
                                    <?php
                                        $result = $dbc->query("SELECT nom_scientifique FROM Espece");

                                        if($result) {
                                            while ($row = mysqli_fetch_array($result))
                                                echo '<option name="nom_scientifique" value="'. $row['nom_scientifique'] . '">' . $row['nom_scientifique'] . '</option>';
                                        }
                                    ?>
                                    </select>

                                 </label> <br />
                                <label><span>Numéro de puce:  </span><br> <input type="number" name="n_puce" min="1" max="2147483647" required> </label> <br />
                                <label><span>Taille:  </span> <br><input type="number" name="taille" min="1" max ="2147483647" required > </label> <br />
                                <label><span>Sexe:  </span> <br>
                                    <input type="radio" name="sexe" value="M" checked > M&acircle
                                    <input type="radio" name="sexe" value="F"> Femelle
                                </label> <br/>
                                <label><span>Date de naissance:  </span> <br>
                                    <input type="text" name="date_naissance" placeholder="<j>j/<m>m/aaaa" required pattern="[1-3]{0,1}[0-9]{1}/[1]{0,1}[0-9]{1}/[0-9]{4}" title="Entrez la date sous ce format <j>j/<m>m/aaaa"/>
                                </label> <br />

                                <label><span>Numéro d'enclos:  </span> <br>
                                    <select name="n_enclos">
                                        <?php
                                            $result = $dbc->query("SELECT n_enclos FROM Enclos");

                                            if($result) {
                                                while ($row = mysqli_fetch_array($result))
                                                    echo '<option name="n_enclos" value="'. $row['n_enclos'] . '">' . $row['n_enclos'] . '</option>';
                                            }
                                         ?>
                                    </select></br>
                                    <label><span>Institution prêtant l'animal:  </span> <br>
                                        <select name="nom_institution">
                                            <?php
                                                $result = $dbc->query("SELECT nom_institution FROM Institution");

                                                if($result) {
                                                    echo '<option name="nom_institution" value="vide">Pas d\'institution</option>';
                                                    echo '<option name="nom_institution" value="Autres">Nouvelle institution</option>';
                                                    while ($row = mysqli_fetch_array($result))
                                                        echo '<option name="nom_institution" value="'. $row['nom_institution'] . '">' . $row['nom_institution'] . '</option>';
                                                }
                                             ?>
                                        </select></br>
                            <br>
                            <input type="submit" name="Ajout_submit" value="Ajout" class="Small_submit" />
                        </fieldset><br />
                    </form>


                </div>
        </div>
    </body>
    </html>
