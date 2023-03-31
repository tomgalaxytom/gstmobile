<?php

use function Composer\Autoload\includeFile;

include __DIR__ . "/includes.php";
$bearerAuthorization = $_SERVER['HTTP_AUTHORIZATION'];
if( $bearerAuthorization != null ){
  echo $bearerAuthorization;
  list( $bearerText, $token) = explode(" ", $bearerAuthorization );
  echo $_SESSION['access_token'];
  print_r( $_SERVER );
} else {
  echo $_SESSION['access_token'];
  echo "invalid request";
}