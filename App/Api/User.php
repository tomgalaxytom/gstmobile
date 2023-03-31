<?php
namespace App\Api;
/**
 * authentication api which is responsible for login, logout, register, forgot, update profile, logincheck ( is_logged_in)
 */

class User extends BaseApi {    
  use \App\Api\Authentication;
  /**
   * register api end point
   */
  public function register(){


   // $this->is_logged_in();
    $user = new \App\Models\User();
    $now = date("Y-m-d H:i:s");
    $postData = $this->post();

    $chargeid = 2;
    $roleid = 20;

    $userData = [
      'mobilenumber'  => $postData["mobilenumber"],
      'name'          => $postData["name"],
      'pwd'           => md5($postData["pwd"]),
      'email'         => $postData["email"],
      'distcode'      => $postData["distcode"],
      'deviceid'      => $postData["deviceid"],
      'ipaddress'     => $postData["ipaddress"],
      'createdon'     => $now,
      'updatedon'     => $now,
      'createdby'     => 1,
      'updatedby'     => 1,
      'chargeid'      =>  $chargeid,
      'roleid'        =>  $roleid,
      'roletypecode'  =>  '06'

    ];






    \App\System\Log::info( json_encode( $userData ));
    \App\System\Log::query('insert', 'mybillmyright.mst_user', $userData);
    $userid = $user->insert($userData);
    
    // $user_id = $user->insertUser( $userData);

    if( $userid ){
      $this->response($this->HTTP_SUCCESS, ['id'=>$userid]);
    } else {
      $this->response($this->HTTP_REGISTER_ERROR);
    }
  }
  public function saveProfile(){
    echo 'stalin';
    exit;
    $this->is_logged_in();
    $user = new \App\Models\User();

    $date = date("Y-m-d");
    $userData = [
      'mobile_no' => $_POST["mobile_no"],
      'last_name' => $_POST["last_name"],
      'first_name' => $_POST["first_name"],
      'mpin' => $_POST["mpin"],
      'email' => $_POST["email"],
      'created_at' => $date,
      'updated_at' => $date
    ];
    $user_id = $_POST['user_id'];
    // just to make sure the user is available in db,
    // if hacker sends anonymous id( random id), then we will treat as 
    // invalid request
    if( !$user->getUser($user_id, 'user_id')){
      $this->response($this->HTTP_INVALID);
    }

    $user->update($userData, ['user_id' => $user_id]);

    if( $user_id ){
      $this->response($this->HTTP_SUCCESS, ['id'=>$user_id]);
    } else {
      $this->response($this->HTTP_API_ERROR);
    }
  }
  public function deleteUser(){
    $user = new \App\Models\User();
    $postData = $this->post();
    $status = $user->delete( ['userid' => $postData['userid']]);
    if( $status ){
      $this->response($this->HTTP_SUCCESS, ['status_a'=>$status]);
    } else {
      $this->response($this->HTTP_API_ERROR);
    }
  }
  /**
   *  get user api
   */
  public function getUser(){
    //$this->is_logged_in();
    $user = new \App\Models\User();
    $postData = $this->post();
    $userId = decode($postData["userid"]);
    $userData = $user->getUser( $userId, "u.userid,u.mobilenumber, u.name,
u.email,u.statecode,u.distcode,u.addr1,u.addr2,u.pincode ,
md.distename as districtname" );
    if( $userData ){
      $this->response($this->HTTP_SUCCESS, $userData);
     // exit;
    } else {
      $this->response($this->HTTP_API_ERROR);
    }
  }
  /**
   *  get user name
   */
  public function editUserName(){

    //$this->is_logged_in();
    $user = new \App\Models\User();
    $postData = $this->post();
    $userId =$postData['userid'];
    $name = $postData['name'];
    $userData = $user->editUserName( $userId, $name );
    if( $userData ){
      $this->response($this->HTTP_SUCCESS, $userData);
    } else {
      $this->response($this->HTTP_API_ERROR);
    }
  }
   /**
   *  Edit Phone Number
   */
  public function editPhoneNumber(){

    //$this->is_logged_in();
    $user = new \App\Models\User();
    $postData = $this->post();
    $userId =$postData['userid'];
    $mobilenumber = $postData['mobilenumber'];
    $userData = $user->editPhoneNumber( $userId, $mobilenumber );
    if( $userData ){
      $this->response($this->HTTP_SUCCESS, $userData);
    } else {
      $this->response($this->HTTP_API_ERROR);
    }
  }
    /**
   *  Edit Email
   */
  public function editEmail(){

    //$this->is_logged_in();
    $user = new \App\Models\User();
    $postData = $this->post();
    $userId = $postData['userid'];
    $email = $postData['email'];
    $userData = $user->editEmail( $userId, $email );
    if( $userData ){
      $this->response($this->HTTP_SUCCESS, $userData);
    } else {
      $this->response($this->HTTP_API_ERROR);
    }
  }

  /**
   *  get pincode
   */
  public function editPincode(){

    //$this->is_logged_in();
    $user = new \App\Models\User();
    $postData = $this->post();
    $userId =$postData['userid'];
    $pincode = $postData['pincode'];
    $userData = $user->editPincode( $userId, $pincode );
    if( $userData ){
      $this->response($this->HTTP_SUCCESS, $userData);
    } else {
      $this->response($this->HTTP_API_ERROR);
    }
  }
  /**
   *  edit Address
   */
  public function editAddress(){

    //$this->is_logged_in();
    $user = new \App\Models\User();
    $postData = $this->post();
    $userId =$postData['userid'];
    $pincode = $postData['address'];
    $userData = $user->editAddress( $userId, $pincode );
    if( $userData ){
      $this->response($this->HTTP_SUCCESS, $userData);
    } else {
      $this->response($this->HTTP_API_ERROR);
    }
  }
    /**
   *  Already Mobile No Exists 
   */
  public function alreadyPhoneNumberExists(){

    //$this->is_logged_in();
    $user = new \App\Models\User();
    $postData = $this->post();
    $mobilenumber = $postData['mobilenumber'];
    $userData = $user->alreadyPhoneNumberExists( $mobilenumber );
    if( $userData[0]['count'] == 0 ){
      $this->response($this->HTTP_SUCCESS, $userData);
    } else {
      $this->response($this->HTTP_API_ERROR);
    }
  }

   /**
   *  get District Name
   */
  public function editDistrictName(){

    //$this->is_logged_in();
    $user = new \App\Models\User();
    $postData = $this->post();
    $userId =$postData['userid'];
    $distcode = $postData['distcode'];
    $userData = $user->editDistrictName( $userId, $distcode );
    if( $userData ){
      $this->response($this->HTTP_SUCCESS, $userData);
    } else {
      $this->response($this->HTTP_API_ERROR);
    }
  }
   /**
   *  Change Password
   */
  public function changePassword(){
    //$this->is_logged_in();
    $user            = new \App\Models\User();
    $postData        = $this->post();
    $userId          = decode($postData["userid"]);
    $currentpassword = trim(md5($postData['currentpassword'])) ;
    $newpassword     = trim(md5($postData['newpassword'])) ;


    // $userId = decode($_POST["userid"]);
    // $currentpassword = $_POST['currentpassword'] ;
    // $newpassword = $_POST['newpassword'] ;

    // $array = array(
    //   "userId" => $userId,
    //   "currentpassword" => md5($currentpassword),
    //   "newpassword" => md5($newpassword),
    // );
    
   
    //$currentpassword = md5($currentpassword);
    //$newpassword = md5($newpassword);

    //echo $array['currentpassword'];


   

    $userData = $user->currentPasswordExists( $userId , $currentpassword);


    if( $userData[0]['count'] == 0 ){
       $this->response($this->HTTP_CURRENT_PASSWORD_ERROR);
       
    }
    else{

      

       $userData = $user->changePassword( $userId ,$newpassword);
            if( $userData ){
              $this->response($this->HTTP_SUCCESS, $userData);
            } else {
              $this->response($this->HTTP_API_ERROR);
            }

    }

    
  }
}
