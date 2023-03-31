<?php
namespace App\Api;
/**
 * authorization class for handling headers from $_SERVER
 */

 class Authorization{
  public $headers;
  public function __construct() {
    $this->headers = $_SERVER;
  }
  private function getHeader($headerName = ''){
    $header = $this->headers[$headerName];
    // if( $header == '' ){
    //   $header = "AUTH NOTGIVEN";
    // }
    return $header;
  }
  public function getBasicAuth(){
    $loginData = [
      "username" => $this->getHeader('PHP_AUTH_USER'),
      "password" => $this->getHeader('PHP_AUTH_PW')
    ];
    return $loginData;
  }
  // get api access token from request
  public function getApiAccessToken(){
    $authorizationHeader = $this->getHeader('HTTP_AUTHORIZATION');
    list($authMode, $authKey) = explode(" ", $authorizationHeader );
    return $authKey;
  }
  //  authorization token generation
  public function generateToken( $length = 16){
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    $charLengh = strlen($chars);
    $randomString = null;
    for( $i = 0; $i<$length; $i++){
      $randomString .= $chars[rand(0, ($charLengh - 1))];
    }
    return $randomString;
  }
  // get local access token
  public function getAccessToken(){
    return @$_SESSION['access_token'] ;
    //return file_get_contents(TMP_PATH . "/tkn_1.txt");
  }
  public function setAccessToken($token){
    // store the token in tmp file
    //file_put_contents(TMP_PATH . "/tkn_1.txt", $token);
    $_SESSION['access_token'] = $token;
  }

}