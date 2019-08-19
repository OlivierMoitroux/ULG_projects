<?php
    include("security.php");
    $_SESSION['loggedIn'] = false;
    session_destroy();
    header('Location: index.html');
?>
