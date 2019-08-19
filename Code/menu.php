<meta charset="utf-8" />
<div class="Menu">
    <?php
        if (!isset($page)){
            header('Location: index.html');
        }
    ?>
    <ul>
        <li id="Menu_field">Menu</li>
        <li><a <?php if($page == 'a'){ echo  'class="active"';}?> href="a.php">a) S&eacutelections g&eacuten&eacuterales</a></li>
        <li><a <?php if($page == 'b'){ echo  'class="active"';}?> href="b.php">b) Classement des annimaux par nombre de v&eacutet&eacuterinaires</a></li>
        <li><a <?php if($page == 'c'){ echo  'class="active"';}?> href="c.php">c) Afficher les techniciens qui ont travaill&eacute dans l'ensemble des enclos du parc animalier</a></li>
        <li><a <?php if($page == 'd'){ echo  'class="active"';}?> href="d.php">d) Proportion d'interventions sur des annimaux mal-log&eacutes</a> </li>
        <li><a <?php if($page == 'e'){ echo  'class="active"';}?> href="e.php">e) Ajout d'un animal dans la base de donn&eacutees</a> </li>

        <li id="Log_out"><a  href="logout.php">D&eacuteconnexion</a></li>
    </ul>

</div>
