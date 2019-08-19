
<html>
    <meta charset="utf-8" />
    <head>
        <title> Projet 2 Base de données </title>
    </head>

    <link rel="stylesheet" type="text/css" href="style.css"/>

    <body>
        <?php include("security.php"); ?>
        <?php $page = "a"; include("menu.php"); ?>

    <!--  ************************* MAIN FIELD ***************************** -->

        <div class = "Main_field">
            <h2>Question 2.a</h2>
            <p>S&eacutelectionnez une table:</p>

            <!-- ****************** TABLE SELECTION *************************-->

            <div class="Table_selection_form">
                    <form method="post" action="">
                        <fieldset >
                                <legend>Tables</legend>
                            <div class="Table_radio">
                                <table>
                                    <tr>
                                        <td><input type="radio" name="table" value="Institution" checked> Institution</td>
                                        <td><input type="radio" name="table" value="Espece" > Esp&egravece</td>
                                        <td><input type="radio" name="table" value="Climat" > Climat</td>
                                    </tr>
                                    <tr>
                                        <td><input type="radio" name="table" value="Animal" > Animal</td>
                                        <td><input type="radio" name="table" value="Enclos" > Enclos</td>
                                        <td><input type="radio" name="table" value="Materiel" > Mat&eacuteriel</td>
                                    </tr>
                                    <tr>
                                        <td><input type="radio" name="table" value="Personnel" > Personnel</td>
                                        <td><input type="radio" name="table" value="Veterinaire" > V&eacutet&eacuterinaire</td>
                                        <td><input type="radio" name="table" value="Technicien" > Technicien</td>
                                    </tr>
                                    <tr>
                                        <td><input type="radio" name="table" value="Intervention" > Intervention</td>
                                        <td><input type="radio" name="table" value="Entretien" > Entretien</td>
                                        <td><input type="radio" name="table" value="Provenance" > Provenance</td>
                                    </tr>
                                </table>
                            </div>
                            <br>
                            <input type="submit" name="submit_table" value="select" class="Small_submit" />
                        </fieldset><br />
                    </form>
            </div>

            <!-- INPUT de texte: comme des ctrl+f et faire des LIKE en sql. -->
            <!-- Pour les input de nombre (puces par exemple), liste déroulante des valeurs dans la table. -->
            <!-- Automatiser les formulaires !! -->

            <?php
            if (isset($_POST['submit_table'])) {
                if(isset($_POST['table'])) {

                    /****************************** INPUT FORMS ************************************************/
            $chosenTable = $_POST['table'];

            // HARDCODE:
            switch ($chosenTable) {
                case 'Institution':
                    echo'
                        <div class="Institution_form">
                            <form method="post" action="select.php">
                                <fieldset >
                                        <legend>Institution</legend>
                                        <input type="hidden" name="table" value='.$chosenTable.'>
                                        <label><span>Nom de l\'institution:  </span> <br><input type="text" name="nom_institution" size="30" maxlength="50"> </label> <br />
                                        <label><span>Rue:  </span><br> <input type="text" name="rue" size="30" maxlength="100"> </label> <br />
                                        <label><span>Code postal:  </span> <br><input type="number" name="code_postal" min="1" max ="2147483647" ></label> <br />
                                        <label><span>Pays:  </span><br> <input type="text" name="pays" size="30" maxlength="50"> </label> <br />

                                    <br>
                                    <input type="submit" value="rechercher" class="Small_submit" />
                                </fieldset><br />
                            </form>
                        </div>
                    ';
                    break;

                case 'Espece':
                    echo '<div class="Espece_form">
                        <form method="post" action="select.php">
                            <fieldset >
                                    <legend>Esp&egravece</legend>
                                    <input type="hidden" name="table" value='.$chosenTable.'>
                                    <label><span>Nom scientifique:  </span> <br><input type="text" name="nom_scientifique" size="30" maxlength="50"> </label> <br />
                                    <label><span>Nom courant:  </span><br> <input type="text" name="nom_courant" size="30" maxlength="50"> </label> <br />
                                    <label><span>R&eacutegime alimentaire:  </span> <br><input type="text" name="regime_alimentaire" size="30" maxlength="50"> </label> <br />
                                <br>
                                <input type="submit" value="rechercher" class="Small_submit" />
                            </fieldset><br />
                        </form>
                    </div>';
                    break;

                case 'Climat':
                    echo '<div class="Climat_form">
                        <form method="post" action="select.php">
                            <fieldset >
                                    <legend>Climat</legend>
                                    <input type="hidden" name="table" value='.$chosenTable.'>
                                    <label><span>Nom scientifique:  </span> <br><input type="text" name="nom_scientifique" size="30" maxlength="50"> </label> <br />
                                    <label><span>Climat:  </span><br> <input type="text" name="nom_climat" size="30" maxlength="50"> </label> <br />
                                <br>
                                <input type="submit" value="rechercher" class="Small_submit" />
                            </fieldset><br />
                        </form>
                    </div>';
                    break;

                case 'Animal':
                    echo'<div class="Animal_form">
                        <form method="post" action="select.php">
                            <fieldset >
                                    <legend>Animal</legend>
                                    <input type="hidden" name="table" value='.$chosenTable.'>
                                    <label><span>Nom scientifique:  </span> <br><input type="text" name="nom_scientifique" size="30" maxlength="50"> </label> <br />
                                    <label><span>Num&eacutero de puce:  </span><br> <input type="number" name="n_puce" min="1" max ="2147483647" > </label> <br />
                                    <label><span>Taille:  </span> <br><input type="number" name="Taille" min="1" max ="2147483647" > </label> <br />
                                    <label><span>Sexe:  </span> <br>
                                        <input type="radio" name="sexe" value="M" checked> M&acircle
                                        <input type="radio" name="sexe" value="F"> Femelle
                                    </label> <br />
                                    <label><span>Date de naissance:  </span> <br>
                                    <input type="text" name="date_naissance" placeholder="<j>j/<m>m/aaaa" pattern="[1-3]{0,1}[0-9]{1}/[1]{0,1}[0-9]{1}/[0-9]{4}" title="Entrez la date sous ce format <j>j/<m>m/aaaa"/>
                                    </label> <br />
                                    <label><span>Num&eacutero d\'enclos:  </span><br> <input type="number" name="n_enclos" min="1" max ="2147483647" > </label> <br />
                                <br>
                                <input type="submit" value="rechercher" class="Small_submit" />
                            </fieldset><br />
                        </form>
                    </div>';
                    break;

                case 'Enclos':
                    echo'<div class="Enclos_form">
                        <form method="post" action="select.php">
                            <fieldset >
                                    <legend>Enclos</legend>
                                    <input type="hidden" name="table" value='.$chosenTable.'>
                                    <label><span>Num&eacutero d\'enclos:  </span><br> <input type="number" name="n_enclos" min="1" max ="2147483647" > </label> <br />
                                    <label><span>Climat:  </span><br> <input type="text" name="climat" size="30" maxlength="50"> </label> <br />
                                    <label><span>Taille:  </span> <br><input type="number" name="Taille" min="1" max ="2147483647" > </label> <br />
                                <br>
                                <input type="submit" value="rechercher" class="Small_submit" />
                            </fieldset><br />
                        </form>
                    </div>';
                    break;

                case 'Materiel':
                    echo' <div class="Materiel_form">
                        <form method="post" action="select.php">
                            <fieldset >
                                    <legend>Mat&eacuteriel</legend>
                                    <input type="hidden" name="table" value='.$chosenTable.'>
                                    <label><span>Num&eacutero mat&eacuteriel:  </span><br> <input type="number" name="n_materiel" min="1" max ="2147483647" > </label> <br />
                                    <label><span>&Eacutetat:  </span><br> <input type="text" name="etat" size="30" maxlength="50"> </label> <br />
                                    <label><span>Local:  </span><br> <input type="text" name="local" size="30" maxlength="50"> </label> <br />
                                <br>
                                <input type="submit" value="rechercher" class="Small_submit" />
                            </fieldset><br />
                        </form>
                    </div>';
                    break;

                case 'Personnel':
                    echo' <div class="Personnel_form">
                        <form method="post" action="select.php">
                            <fieldset >
                                    <legend>Personnel</legend>
                                    <input type="hidden" name="table" value='.$chosenTable.'>
                                    <label><span>n_registre:  </span><br> <input type="number" name="n_registre" min="1" max ="2147483647" > </label> <br />
                                    <label><span>Pr&eacutenom:  </span> <br><input type="text" name="prenom" size="30" maxlength="50"> </label> <br />
                                    <label><span>Nom:  </span> <br><input type="text" name="nom" size="30" maxlength="50"> </label> <br />
                                <br>
                                <input type="submit" value="rechercher" class="Small_submit" />
                            </fieldset><br />
                        </form>
                    </div>';
                    break;

                case 'Veterinaire':
                    echo '<div class="Veterinaire_form">
                        <form method="post" action="select.php">
                            <fieldset >
                                    <legend>V&eacutet&eacuterinaire</legend>
                                    <input type="hidden" name="table" value='.$chosenTable.'>
                                    <label><span>Num&eacutero de registre:  </span><br> <input type="number" name="n_registre" min="1" max ="2147483647" > </label> <br />
                                    <label><span>Num&eacutero de license:  </span><br> <input type="number" name="n_license" min="1" max ="9223372036854775807" > </label> <br />
                                    <label><span>Sp&eacutecialit&eacute:  </span> <br><input type="text" name="specialite" size="30" maxlength="50"> </label> <br />
                                <br>
                                <input type="submit" value="rechercher" class="Small_submit" />
                            </fieldset><br />
                        </form>
                    </div>';
                    break;

                case 'Technicien':
                    echo'<div class="Technicien_form">
                        <form method="post" action="select.php">
                            <fieldset >
                                    <legend>Technicien</legend>
                                    <input type="hidden" name="table" value='.$chosenTable.'>
                                    <label><span>Num&eacutero de registre:  </span><br> <input type="number" name="n_registre" min="1" max ="2147483647" > </label> <br />
                                <br>
                                <input type="submit" value="rechercher" class="Small_submit" />
                            </fieldset><br />
                        </form>
                    </div>';
                    break;

                case 'Intervention':
                    echo '<div class="Intervention">
                        <form method="post" action="select.php">
                            <fieldset >
                                    <legend>Intervention</legend>
                                    <input type="hidden" name="table" value='.$chosenTable.'>
                                    <label><span>Num&eacutero d\'intervention:  </span><br> <input type="number" name="n_intervention" min="1" max ="2147483647" > </label> <br />
                                    <label><span>Date:  </span> <br>
                                    <input type="text" name="date" placeholder="<j>j/<m>m/aaaa" pattern="[1-3]{0,1}[0-9]{1}/[1]{0,1}[0-9]{1}/[0-9]{4}" title="Entrez la date sous ce format <j>j/<m>m/aaaa"/>
                                     </label> <br />
                                    <label for="comments"><span>Description:</span></label><br />
                                        <textarea rows="4" cols="70" id="description" placeholder="Ecrivez du texte ici" maxlength="65535"></textarea></br>
                                    <label><span>Num&eacutero de registre:  </span><br> <input type="number" name="n_registre" min="1" max ="2147483647" > </label> <br />
                                    <label><span>Nom scientifique:  </span> <br><input type="text" name="nom_scientifique" size="30" maxlength="50"> </label> <br />
                                    <label><span>Num&eacutero de puce:  </span><br> <input type="number" name="n_puce" min="1" max ="2147483647" > </label> <br />
                                <br>
                                <input type="submit" value="rechercher" class="Small_submit" />
                            </fieldset><br />
                        </form>
                    </div>';
                    break;

                case 'Entretien':
                    echo'<div class="Entretien">
                        <form method="post" action="select.php">
                            <fieldset >
                                    <legend>Entretien</legend>
                                    <input type="hidden" name="table" value='.$chosenTable.'>
                                    <label><span>Num&eacutero d\'entretien:  </span><br> <input type="number" name="n_entretien" min="1" max ="2147483647" > </label> <br />
                                    <label><span>Num&eacutero de registre:  </span><br> <input type="number" name="n_registre" min="1" max ="2147483647" > </label> <br />
                                    <label><span>Num&eacutero mat&eacuteriel:  </span><br> <input type="number" name="n_materiel" min="1" max ="2147483647" > </label> <br />
                                    <label><span>Date:  </span> <br><input type="text" name="date" placeholder="<j>j/<m>m/aaaa"> </label> <br />
                                    <label><span>Num&eacutero d\'enclos:  </span><br> <input type="number" name="n_enclos" min="1" max ="2147483647" > </label> <br />
                                <br>
                                <input type="submit" value="rechercher" class="Small_submit" />
                            </fieldset><br />
                        </form>
                    </div>';
                    break;

                case 'Provenance':
                    echo'<div class="Provenance">
                        <form method="post" action="select.php">
                            <fieldset >
                                    <legend>Provenance</legend>
                                    <input type="hidden" name="table" value='.$chosenTable.'>
                                    <label><span>Nom scientifique:  </span> <br><input type="text" name="nom_scientifique" size="30" maxlength="50"> </label> <br />
                                    <label><span>Num&eacutero de puce:  </span><br> <input type="number" name="n_puce" min="1" max ="2147483647" > </label> <br />
                                    <label><span>Nom de l\'institution:  </span> <br><input type="text" name="nom_institution" size="30" maxlength="50"> </label> <br />
                                <br>
                                <input type="submit" value="rechercher" class="Small_submit" />
                            </fieldset><br />
                        </form>
                    </div>';
                    break;
                default:
                    echo 'Table inconnue';
                    break;
            }
        }
    }

    ?>

    </div>

    </body>
    </html>
