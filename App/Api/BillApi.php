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
  public function saveBill(){
    // $this->is_logged_in();
    $postData = $this->post();
    $billId = $postData['billdetailid'];
    Log::info(print_r($postData, true));
    if( $postData['baseimage'] == ''){
      unset($postData['baseimage']);
    }
    if( !isset($postData["distcode"]) ||   !isset($postData['billnumber']) || !isset($postData['billdate']) || !isset($postData['shopname']) || !isset($postData['billamount']) || ($billId == "" && !isset($postData['baseimage']) )){
      $this->response( $this->HTTP_INVALID );
    }
    // Log::info( print_r( $postData, true ));
    // mime type validation when image is present 
    if( isset($postData['baseimage'])){
      if(!CommonHelper::isValidBill(base64_decode($postData['baseimage']), true)){
        Log::error( "Mime Type error: " .CommonHelper::getFileMimeType(base64_decode($postData['baseimage']), true));
        $this->response($this->HTTP_API_ERROR);
      }
    }
    
    $billModel    = new \App\Models\Bill();
    $userId       = decode($postData["userid"]);
    $distcode     = trim($postData["distcode"]);
    $billnumber   = trim($postData["billnumber"]) ;
    $billdate     = trim($postData["billdate"]) ;
    $billdate     = date("Y-m-d",strtotime($billdate));
    $shopname     = trim($postData["shopname"]) ;
    $billamount   = trim($postData["billamount"]);
    $uploadedon   = date("Y-m-d H:i:s") ;
    $uploadedby   = trim($userId);
    $acknumber    = $this->getAwkNumber( $this->post('distcode'),$billnumber );
    $getconfigArray   = $this->getConfigandMobileNumber( $distcode ) ;
    $configArray  = explode("/",$getconfigArray);
    $configcode   = $configArray[0];
    $mobilenumber = trim($postData["mobilenumber"]);

    $billData = [
    'userid'        => $userId,
    'statecode'     => 'TN',//For TamilNadu
    'configcode'    => $configcode,
    'acknumber'     => $acknumber,
    'distcode'      => $distcode,
    'mobilenumber'  => $mobilenumber,
    'billnumber'    => $billnumber,
    'billdate'      => $billdate,
    'shopname'      => $shopname,
    'billamount'    =>  $billamount,
    'uploadedon'    => date("Y-m-d H:i:s"),
    'uploadedby'    => $userId,
    'statusflag'    => "N"
    ];


    echo

    \App\System\Log::query( 'insert', 'mybillmyright.billdetail', $billData);

 // \App\System\Log::info( json_encode( $userData ));
 //    \App\System\Log::query('insert', 'mybillmyright.mst_user', $userData);



     if( $billId ){
      $billModel->update($billData, ['billdetailid' => $billId]);
     } else {
      $billId = $billModel->insert($billData);
     }
     

     if( $billId  ){
      if( isset($postData['baseimage'])){
        $this->processImage($postData, $billId);
      }




      $this->response($this->HTTP_SUCCESS, ['id' => $billId ,'acknumber' =>$acknumber ]);
     } else {
      $this->response($this->HTTP_SAVEBILL_ERROR);// chagne the error message now 
     }
   }

   /**
    * process image 
    *
    * @return void
    */
    private function processImage( $postData, $billId ){
        $userId = decode($postData["userid"]);
        // make the bill flder like this uploads/bills/{$userId}/$billId/$filename.$fileextension
        $config   = new \App\System\Config();
        $uploadBasePath      = $config->get("bill_uploads");

        $currentYear = date("Y"); 
        $distcode    = $postData["distcode"] ;
        $billDate       = $postData["billdate"] ;
        $month = date('m', strtotime($billDate));


       
        /***
         *
         * 
         * $uploadPath = $uploadBasePath . DIRECTORY_SEPARATOR . $userId . DIRECTORY_SEPARATOR . $billId;
         * 
         *  
         * **/

        $uploadPath = $uploadBasePath . DIRECTORY_SEPARATOR . $currentYear . DIRECTORY_SEPARATOR . $distcode. DIRECTORY_SEPARATOR . $month;
        





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


         /***
         *
         * 
         *  $fileTmpPath = $userId . "/" . $billId . "/" . $fileTmpName;
         * 
         *  
         * **/

         $fileTmpPath = $currentYear . "/" . $distcode . "/" . $month. "/" . $fileTmpName;


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
         $billModel = new \App\Models\Bill();
         if( !$billModel->update( $updateData,['billdetailid' => $billId] )){
          Log::query( 'update', 'mybillmyright.billdetail', $updateData, $billId);
          Log::info("Bill added, but the files details not added due to query error, Query above");
        }
        $acknumber = $this->getAwkNumber( $postData["distcode"],$postData["billnumber"] ) ;
        $this->response($this->HTTP_SUCCESS, ['id' => $billId,'acknumber' =>$acknumber] );
        } else {
          Log::error( "Mime Type error: " . $mimeType);
          $this->response($this->HTTP_API_ERROR);
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
     * get Invoices based DateRange
     */
    public function getInvoicesbasedDateRange(){
     //  if( $this->is_logged_in() ){
 
    
       $billModel = new \App\Models\Bill();
       //For Office Uses Only
       $postData = $this->post();
       $userId = decode($postData["userid"]);
     // $dateRange = $postData["dateRangeValue"];
       //For Office Uses Only
       //For Debug  Only
       // echo '<pre>';
       // print_r($_POST);
       // exit;
      // $userId = decode($_POST["userid"]);
       //$dateRange = $_POST["dateRangeValue"];
       //For Debug  Only
      // $t = "2022-11-28 00:00:00.000 - 2022-11-30 00:00:00.000";
       //$datearray = explode('-',$dateRange);
      // $sdate = substr($datearray[2],0,2);
       $sdate = $postData["startdate"];
       $startdate = date("Y-m-d", strtotime($sdate));
       $ldate = $postData["enddate"];
       $enddate = date("Y-m-d", strtotime($ldate));
       $message = $postData["message"];
      if(isset( $message) && trim( $message) != "") { 
        $getInvoiceList = $billModel->getInvoicesbasedDateRange(  $startdate , $enddate,$userId,$message );
       }
      else { 
        $getInvoiceList = $billModel->getInvoicesbasedDateRange(  $startdate , $enddate,$userId );
      }
       // search query string from request
       
       //$districts = $district->getDistrictByStateCode($statecode,'distename,disttname');
       $this->response( $this->HTTP_SUCCESS, $getInvoiceList);
   // }
   }

    /**
     * getAwknowledgement no
     */
    private function getAwkNumber( $distcode ,$billnumber ){

        $lastthreedigitsofInvoicenumber = substr($billnumber, -3);
      
        $billModel = new \App\Models\Bill();
        $getAwkDetails = $billModel->getAwkNumber($distcode);
        if( !$getAwkDetails ){
          Log::error('Acknowledgement Not Found');
          $this->response( $this->HTTP_INVALID );
        }
       // return $awkNo =  $getAwkDetails['yearmonth'].$getAwkDetails['deviceid'].$getAwkDetails['distcode'].'0000001';

        // Yearmonth(6)/Distcode(3)/mobilenumber(last 3 digit)/LAst 3 numbers of invoice(3 digit)+Random number(6)   -> 21 Digit
        // ex:
        //   202301/CHN/378/123/000001


         return $awkNo =  $getAwkDetails['yearmonth']."/".$getAwkDetails['distcode']."/".$getAwkDetails['mobilenumber']."/".$lastthreedigitsofInvoicenumber."/".'000001';

    }

    /**
     * getAwknowledgement no
     */

  /**
     * getConfigno and Mobile Number
     */
    private function getConfigandMobileNumber( $distcode ){
        $billModel = new \App\Models\Bill();
        $getConfandmobileDetails = $billModel->getConfigandMobileNumber($distcode);
        if( !$getConfandmobileDetails ){
          Log::error('MobileNimber Not Found');
          $this->response( $this->HTTP_INVALID );
        }
       // return $awkNo =  $getAwkDetails['yearmonth'].$getAwkDetails['deviceid'].$getAwkDetails['distcode'].'0000001';

        // Yearmonth(6)/Distcode(3)/mobilenumber(last 3 digit)/LAst 3 numbers of invoice(3 digit)+Random number(6)   -> 21 Digit
        // ex:
        //   202301/CHN/378/123/000001


         return $configandMobileNo =  $getConfandmobileDetails['configcode']."/".$getConfandmobileDetails['mobilenumber'];

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
     /**
     *  Get Based Config Start Date,End Date Picker
     */
    public function configBasedStartDateEndDate(){
        $billModel = new \App\Models\Bill();
        $postData = $this->post();
        $distcode =      $postData["distcode"] ;
        $userData = $billModel->configBasedStartDateEndDate(  $distcode );
        if( $userData ){
          $this->response($this->HTTP_SUCCESS, $userData);
        } else {
          $this->response($this->HTTP_API_ERROR);
        }
    }
     public function getInvoiceCountBasedBillStartandEndDate(){
        $billModel = new \App\Models\Bill();
        $invoiceCount = $billModel->getInvoiceCountBasedBillStartandEndDate();
        $this->response( $this->HTTP_SUCCESS, $invoiceCount);
    }
    
  
 }