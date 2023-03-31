<?php
namespace App\Api;
/**
 * include dependencies
 */


use App\Api\Authorization;
use App\System\Secure\Encrypt;
use App\System\Log;

/**
 * class api
 */
class BaseApi extends Authorization{
  use \App\Api\Response;
  private $accessToken;

  /**
   * @param $object, $method
   * check if the api command  / method exists
   */
  public function validCommand( $object, $method ){
    if( false == method_exists($object, $method ) ){
      $this->response($this->HTTP_INVALID_API);
    }
  }
  /**
   * api execution enter here
   */
  public function execute($command = null){
    $apiClassMethod = $this->getApiMethod($command);
    list( $className, $method ) = $apiClassMethod;
    if( $className == "") $this->response( $this->HTTP_INVALID );
    $object = new $className();
    
    $this->validCommand($object, $method );

    // call the function     
    call_user_func( [$object, $method]);
    
    // if the control comes here, means invalid request, its like default operation
    $this->response( $this->HTTP_INVALID );
  }
  private function getPostData(){
    // here we should decrypt the data from post, lets do this later once you integrated the encryption in flutter
    //@todo: This has to be checked for decrypt when encryption enabled in flutter
    $postData = $_POST['__frmData'];
    $encrypt = new Encrypt();
    $postData = $encrypt->decrypt($postData);
    $postData = json_decode( $postData, true ); //error
    if( empty($postData )){
      $this->response($this->HTTP_API_ERROR);
    }

    return $postData;
  }

  /**
   * post method retrieval functin
   *
   * @param string $key
   * @return $value
   */
  protected function post($key = null, $default = null ){
    if( $key == null ){
      return $this->getPostData();
    }

    // specific key 
    $value = $this->getPostData()[$key] ?? $default;
    return $value;
  }

  /***
   * get api class and method using routes
   */
  private function getApiMethod($command){
    $routes = include_once( ROOT_PATH . DIRECTORY_SEPARATOR . "routes.php");
    return $routes[$command] ?? "";
  }
  // check already login
  public function is_logged_in(){
    // check if the user is logged in already, means checks the token against session access token
    echo  $this->getAccessToken() . "==" . $this->getApiAccessToken();
    exit;
    if( $this->getApiAccessToken() == "" || $this->getAccessToken() == "" ){
      $this->response($this->HTTP_UNAUTHORIZED);
    }
    if( $this->getAccessToken() == $this->getApiAccessToken()){
      return true;
    } else {
      $this->response($this->HTTP_UNAUTHORIZED);
    }
  }

}