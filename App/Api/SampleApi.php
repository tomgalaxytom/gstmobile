<?php

namespace App\Api;
/**
 * sample api 
 */

 class SampleApi extends BaseApi{
      // api for get records
  public function getRecords(){
    if( $this->is_logged_in() ){
      $u = new \App\Models\User();
      $records = $u->query('SELECT * from users');
      $this->response($this->HTTP_SUCCESS, $records );
    }
  }

  public function test(){
    $enc = new \App\system\Secure\Encrypt();
    $string = "mervin thomas";
    $enct  = $enc->encrypt($string);
    echo "a: " . $enct;
    echo "<br/>b" . $enc->decrypt($enct);
    exit;
  }
 }