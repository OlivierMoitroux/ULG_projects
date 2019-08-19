<meta charset="utf-8" />
<?php

    define("DB_USER", "group6");
    define("DB_PASSWORD", "LB//N/1vMJ");

    // get inputs from the login form
    $user_name = $_POST['name'];
    $password = $_POST['pswd'];

    // start a session
    session_start();
    // by default, logged out
    $_SESSION['loggedIn'] = false;

    if ($user_name == DB_USER && $password == DB_PASSWORD) {

        $_SESSION['loggedIn'] = true;

        // Redirection
        header('Location: a.php');
    }

    else {
        header( 'Refresh:4;url=index.html');
        echo "Wrong ID or password";
    }
?>
