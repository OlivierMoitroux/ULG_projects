<?php
	session_start();

	if(!isset($_SESSION['loggedIn']) OR $_SESSION['loggedIn'] = false)
	{
		header('Location: index.html');
	}
?>
