<?php
namespace App;
/**
 * Test Data
 */
class TestData{
  public $data = [];
  public function __construct()
  {
    //$this->data  = $this->fake(40);
  }
  public function fake($count = 10){
    $data = [];
    for( $i=0; $i<$count;$i++){
      $id = $i + 1;
      $data[$i] = [
        "id" => $id,
        "name" => "Name $id",
        "email" => "email{$id}@codelooms.com",
        "username" => "username{$id}"
      ];
    }
    return $data;
  }
}