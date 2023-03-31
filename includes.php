<?php
//some common constants and reusable functions here 
session_start();
// SUCCESS CODE
define('HTTP_CODE_SUCCESS', 200);
// ERROR CODES
define('HTTP_CODE_INVALID_REQUEST', 400);
define('HTTP_CODE_UNAUTHORIZED', 401);
// define('ERROR_CODE_ACCESS_DENIED', 403);
// define('ERROR_CODE_INVALID_REQUEST', 400);

function getRandomPassword( $length = 8 ){
  $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
  $charLengh = strlen($chars);
  $randomString = null;
  for( $i = 0; $i<$length; $i++){
    $randomString .= $chars[rand(0, ($charLengh - 1))];
  }
  return $randomString;
}