<?php

namespace App\Api;
/**
 * sample api 
 */

 class StateApi extends BaseApi{
      // api for get states
  public function getStates(){
  //  if( $this->is_logged_in() ){
      $state = new \App\Models\State();
      $records = $state->getStates('stateid,statecode,stateename');
      $this->response($this->HTTP_SUCCESS, ["states" => $records, "default_state" => "TN"] );
   // }
  }
  /**
   * api for getting districts based on the statecode 
   */
  public function getDistricts($params = []){
 
    //  if( $this->is_logged_in() ){
      $statecode = 'TN';
      if( !isset($statecode) || $statecode == ""){
        $this->response($this->HTTP_INVALID);
      }
      $district = new \App\Models\District();
      $districts = $district->getDistrictByStateCode($statecode,$params['config'] ?? false);
     // echo '<pre>';
     // print_r($districts);
     // exit;
      //$districts = $district->getDistrictByStateCode($statecode,'distename,disttname');
      $this->response( $this->HTTP_SUCCESS, $districts);
  // }
  }
  /**
   * api for getting districts based on the statecode 
   */
  public function getDistrictsConfig($params = []){
 
    //  if( $this->is_logged_in() ){
      $statecode = 'TN';
      if( !isset($statecode) || $statecode == ""){
        $this->response($this->HTTP_INVALID);
      }
      $district = new \App\Models\District();
      $districts = $district->getDistrictByStateCode($statecode,true ?? false);
     // echo '<pre>';
     // print_r($districts);
     // exit;
      //$districts = $district->getDistrictByStateCode($statecode,'distename,disttname');
      $this->response( $this->HTTP_SUCCESS, $districts);
  // }
  }
 }