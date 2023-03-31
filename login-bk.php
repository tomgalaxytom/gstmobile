<?php
include __DIR__ . "/includes.php";
print_r( $_SERVER ); 
// basic authorization using BEARER Auth
$apiUser = 'tom@codelooms.com';
$apiPassword = 'mervinthomas';

// check for authorization
$requestApiUser = $_SERVER['PHP_AUTH_USER'] ?? '';
$requestApiPwd = $_SERVER['PHP_AUTH_PW'] ?? '';

if( $requestApiUser == ''){
  header('WWW-Authenticate: Basic realm="My Website"');
    header('HTTP/1.0 401 Unauthorized');
    exit("Un Authorized");
    exit;
}
// echo $requestApiUser . ":" . $requestApiPwd;
if( $requestApiUser == "" || $requestApiPwd == ""){
  $responseCode  = HTTP_CODE_INVALID_REQUEST;
  $responseMessage = "Invalid Request";
} else if( $apiUser == $requestApiUser && $apiPassword == $requestApiPwd){
  // authorization successfull
  $responseCode = HTTP_CODE_SUCCESS;
  $responseMessage = "Authorized";
  $accessToken  = getRandomPassword(64);
  $_SESSION['access_token'] = $accessToken;
} else {
  $responseCode  = HTTP_CODE_UNAUTHORIZED;
  $responseMessage = "Un Authorized or Access denied";
}

$response = [];
if( $responseCode != 200 ){
  $response['status' ] =  'error';
} else {
  // authorization successfull, continue operations
  $response['status'] = 'success';
  $response['token'] = $accessToken;
}
$response['message'] = $responseMessage;

// send the response to user 
header("HTTP/1.2 {$responseCode} $responseMessage");
exit( json_encode($response));
?>