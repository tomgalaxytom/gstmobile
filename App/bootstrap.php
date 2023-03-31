<?php
/**
 * entry point to the app
 */
define("ROOT_PATH", realpath(__DIR__ . "/../"));
// include helper functions
include_once ( ROOT_PATH . DIRECTORY_SEPARATOR . "functions.php");

// check and start session if its alredy not started
if( session_status() == PHP_SESSION_NONE ){
    // check session id available ;from request, if yes, start with the session id 
    $requestSessionId = $_POST['session_id'] ?? '';
    session_id( $requestSessionId );
    session_start();
}

spl_autoload_register(function ($class) {
    $class = ROOT_PATH . DIRECTORY_SEPARATOR . str_replace("\\", DIRECTORY_SEPARATOR , $class);
    
    try{
        include_once( $class . ".php");
    } catch ( Exception $e ){
        //throw $e->getString();
    }
});