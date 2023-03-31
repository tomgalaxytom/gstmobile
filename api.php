<?php
/**
 * api entry point
 */
error_reporting(0);
include (__DIR__ . "/App/bootstrap.php");

$cmd = $_REQUEST['cmd'] ?? '';
$cmd = trim($cmd, "/");
$api = new App\Api\BaseApi();

$api->execute( $cmd );

?>