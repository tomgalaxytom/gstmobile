<?php

namespace App\Api;
use \App\System\Log;
use \App\Helpers\CommonHelper;
use App\System\Config;

/**
 * Bill api 
 */

 class BillApi extends BaseApi{
  //Add Bill API
  public function addBillForm(){


//echo "ADD" ;

    // $this->is_logged_in();
    $postData = $this->post();
    if( !isset($postData["distcode"]) || !isset($postData['mobilenumber']) ||  !isset($postData['billnumber']) || !isset($postData['billdate']) || !isset($postData['shopname']) || !isset($postData['billamount']) || !isset($postData['baseimage'])){
      $this->response( $this->HTTP_INVALID );
    }
    // Log::info( print_r( $postData, true ));
    // mime type validation 
    if(!CommonHelper::isValidBill(base64_decode($postData['baseimage']), true)){
      Log::error( "Mime Type error: " .CommonHelper::getFileMimeType(base64_decode($postData['baseimage']), true));
      $this->response($this->HTTP_API_ERROR);
    }
    $acknumber  = $this->getAwkNumber( $this->post('distcode') );
    $billModel = new \App\Models\Bill();
    $configcode = '03';
   
   
     $postData = $this->post();
     $userId = decode($postData["userid"]);

     $distcode     = trim($postData["distcode"]);
     $mobilenumber = trim($postData["mobilenumber"]);
     $billnumber   = trim($postData["billnumber"]) ;
     $billdate     = trim($postData["billdate"]) ;
     $shopname     = trim($postData["shopname"]) ;
     $billamount   = trim($postData["billamount"]);
     $uploadedon   = date("Y-m-d H:i:s") ;
     $uploadedby   = trim($userId);


     $billData = [
      'userid' => $userId,
      'statecode' => 'TN',//For TamilNadu
      'configcode' => $configcode,
      'acknumber' => $acknumber,
       'distcode' => $distcode,
       'mobilenumber' => $mobilenumber,
       'billnumber' => $billnumber,
       'billdate' => $billdate,
       'shopname' => $shopname,
       'billamount' =>  $billamount,
       'uploadedon' => date("Y-m-d H:i:s"),
       'uploadedby' => $userId
       
     ];

     Log::query( 'insert', 'mybillmyright.billdetail', $billData);

     $billId = $billModel->insert($billData);
     

     if( $billId ){
        // make the bill flder like this uploads/bills/{$userId}/$billId/$filename.$fileextension
        $config   = new \App\System\Config();
        $uploadBasePath      = $config->get("bill_uploads");
        $uploadPath = $uploadBasePath . DIRECTORY_SEPARATOR . $userId . DIRECTORY_SEPARATOR . $billId;
        if( !is_dir ($uploadPath) ){
        if( !mkdir( $uploadPath, 0777, true ) ){
          // file permission error 
          // log the error to log.txt
          Log::error('Folder Permission Error while creating folder ' . $uploadPath);
        } else {
          Log::info('Folder created successfully ' . $uploadPath);
        }
        }

        // start uploading of files 
        $fileName = $postData['filename'];
        $fileTmpName =  md5(time()) . "_" . $fileName;
        $fileTmpPath = $userId . "/" . $billId . "/" . $fileTmpName;
        $targetFilePath = $uploadPath . DIRECTORY_SEPARATOR . $fileTmpName;
        $fileContent = base64_decode( $postData['baseimage'] );
        CommonHelper::saveFile( $fileContent, $targetFilePath);

        $fileSize = CommonHelper::getFileSize($targetFilePath, true );
        $mimeType = CommonHelper::getFileMimeType($targetFilePath);
        if( CommonHelper::isValidBill($targetFilePath)){
        
        $filePathArray = explode(".", $fileName);
        $fileextension = end($filePathArray);
        // update the bill with the file name
        $updateData = [
          "filename"       => $fileTmpName ,
          "fileextension"  => $fileextension ,
          "mimetype"       => $mimeType ,
          "filesize"       => $fileSize ,
          "filepath"       => $fileTmpPath,
        ];
        // Log::query( 'update', 'mybillmyright.billdetail', $updateData, $billId);
        // $billModel->update( $updateData, ['billdetailid' => $billId]);

         if( !$billModel->update( $updateData,['billdetailid' => $billId] )){
          Log::query( 'update', 'mybillmyright.billdetail', $updateData, $billId);
          Log::info("Bill added, but the files details not added due to query error, Query above");
        }



        $this->response($this->HTTP_SUCCESS, ['id' => $billId]);
        } else {
          Log::error( "Mime Type error: " . $mimeType);
          $this->response($this->HTTP_API_ERROR);
        }
        
     } else {
      $this->response($this->HTTP_REGISTER_ERROR);
     }
   }

   //Add Bill API
  public function EditBillForm(){

   // echo "EDIT";
    // $this->is_logged_in();
    $postData = $this->post();
    if( !isset($postData["distcode"]) || !isset($postData['mobilenumber']) ||  !isset($postData['billnumber']) || !isset($postData['billdate']) || !isset($postData['shopname']) || !isset($postData['billamount']) || !isset($postData['baseimage'])){
      $this->response( $this->HTTP_INVALID );
    }
    // Log::info( print_r( $postData, true ));
    // mime type validation 
    if(!CommonHelper::isValidBill(base64_decode($postData['baseimage']), true)){
      Log::error( "Mime Type error: " .CommonHelper::getFileMimeType(base64_decode($postData['baseimage']), true));
      $this->response($this->HTTP_API_ERROR);
    }
    $acknumber  = $this->getAwkNumber( $this->post('distcode') );
    $billModel = new \App\Models\Bill();
    $configcode = '02';
   
   
     $postData     = $this->post();
     $userId       = decode($postData["userid"]);
     $billId       = $postData["billdetailid"];

     //echo $billId;
    // exit;

     $distcode     = trim($postData["distcode"]);
     $mobilenumber = trim($postData["mobilenumber"]);
     $billnumber   = trim($postData["billnumber"]) ;
     $billdate     = trim($postData["billdate"]) ;
     $shopname     = trim($postData["shopname"]) ;
     $billamount   = trim($postData["billamount"]);
     $uploadedon   = date("Y-m-d H:i:s") ;
     $uploadedby   = trim($userId);


     $billData = [
      'userid'        => $userId,
      'statecode'     => 'TN',//For TamilNadu
      'configcode'    => $configcode,
      'acknumber'     => $acknumber,
       'distcode'     => $distcode,
       'mobilenumber' => $mobilenumber,
       'billnumber'   => $billnumber,
       'billdate'     => $billdate,
       'shopname'     => $shopname,
       'billamount'   =>  $billamount,
       'uploadedon'   => date("Y-m-d H:i:s"),
       'uploadedby'   => $userId
       
     ];

    
   
   $billModel->update($billData, ['billdetailid' => $billId]);
   
   
     if( $billId ){
        // make the bill flder like this uploads/bills/{$userId}/$billId/$filename.$fileextension
        $config   = new \App\System\Config();
        $uploadBasePath      = $config->get("bill_uploads");
        $uploadPath = $uploadBasePath . DIRECTORY_SEPARATOR . $userId . DIRECTORY_SEPARATOR . $billId;
        if( !is_dir ($uploadPath) ){
        if( !mkdir( $uploadPath, 0777, true ) ){
          // file permission error 
          // log the error to log.txt
          Log::error('Folder Permission Error while creating folder ' . $uploadPath);
        } else {
          Log::info('Folder created successfully ' . $uploadPath);
        }
        }

        // start uploading of files 
        $fileName = $postData['filename'];
        $fileTmpName =  md5(time()) . "_" . $fileName;
        $fileTmpPath = $userId . "/" . $billId . "/" . $fileTmpName;
        $targetFilePath = $uploadPath . DIRECTORY_SEPARATOR . $fileTmpName;
        $fileContent = base64_decode( $postData['baseimage'] );
        CommonHelper::saveFile( $fileContent, $targetFilePath);

        $fileSize = CommonHelper::getFileSize($targetFilePath, true );
        $mimeType = CommonHelper::getFileMimeType($targetFilePath);
        if( CommonHelper::isValidBill($targetFilePath)){
        
        $filePathArray = explode(".", $fileName);
        $fileextension = end($filePathArray);
        // update the bill with the file name
        $updateData = [
          "filename"       => $fileTmpName ,
          "fileextension"  => $fileextension ,
          "mimetype"       => $mimeType ,
          "filesize"       => $fileSize ,
          "filepath"       => $fileTmpPath,
        ];
       // Log::query( 'update', 'mybillmyright.billdetail', $updateData, $billId);


       // $billModel->update( $updateData, ['billdetailid' => $billId] );



         if( !$billModel->update( $updateData,['billdetailid' => $billId] )){
          Log::query( 'update', 'mybillmyright.billdetail', $updateData, $billId);
          Log::info("Bill added, but the files details not added due to query error, Query above");
        }


        $this->response($this->HTTP_SUCCESS, ['id' => $billId]);
        } else {
          Log::error( "Mime Type error: " . $mimeType);
          $this->response($this->HTTP_API_ERROR);
        }
        
     } else {
      $this->response($this->HTTP_REGISTER_ERROR);
     }
   }
    /**
     * get Invoices
     */
    public function getInvoices(){
      //  if( $this->is_logged_in() ){
      
        $billModel = new \App\Models\Bill();
        $postData = $this->post();
        $userId = decode($postData["userid"]);


        
        // search query string from request
        $getInvoiceList = $billModel->getInvoices( $this->post('q') ?? null , $userId );
        //$districts = $district->getDistrictByStateCode($statecode,'distename,disttname');
        $this->response( $this->HTTP_SUCCESS, $getInvoiceList);
    // }
    }


/**
     * get Invoices History
     */
    public function getInvoicesHistory(){
      //  if( $this->is_logged_in() ){
      
        $billModel = new \App\Models\Bill();
        $postData = $this->post();
        $userId = decode($postData["userid"]);


        
        // search query string from request
        $getInvoiceList = $billModel->getInvoicesHistory( $this->post('q') ?? null , $userId );
        //$districts = $district->getDistrictByStateCode($statecode,'distename,disttname');
        $this->response( $this->HTTP_SUCCESS, $getInvoiceList);
    // }
    }










    /**
     * getAwknowledgement no
     */
    private function getAwkNumber( $distcode ){
      
        $billModel = new \App\Models\Bill();
        $getAwkDetails = $billModel->getAwkNumber($distcode);
        if( !$getAwkDetails ){
          Log::error('Acknowledgement Not Found');
          $this->response( $this->HTTP_INVALID );
        }
        return $awkNo =  $getAwkDetails['yearmonth'].$getAwkDetails['deviceid'].$getAwkDetails['distcode'].'0000001';

    }

    /**
     * getAwknowledgement no
     */
    public function billNumberFinalize(){
        $billModel = new \App\Models\Bill();
        $postData = $this->post();
        $billId =      $postData["billdetailid"] ;
        $userData = $billModel->updateBillNumberStatusFlag(  $billId );
        if( $userData ){
          $this->response($this->HTTP_SUCCESS, $billId);
        } else {
          $this->response($this->HTTP_API_ERROR);
        }
    }
    
  
 }