<?php
namespace App\System;

class Config
{
  // private $db_driver = "mysql";
  // private $db_host = "localhost";
  // private $db_name = "codelooms34_krnaturelive";
  // private $db_user = "codelooms34_krnaturelive";
  // private $db_password = '2e5$iA|b"COk>30j';

  //Local Mysql

  // private $db_driver = "mysql";
  // private $db_host = "localhost";
  // private $db_port = "3306";
  // private $db_name = "ctax";
  // private $db_user = "root";
  // private $db_password = '';

    //Local Mysql

// pgsql
   
  private $db_driver = "pgsql";
  private $db_host = "localhost";
  private $db_port = "5432";
  private $db_name = "ctax";
  private $db_user = "nursec";
  private $db_password = 'NrC@321#';
  private $db_schema = 'mybillmyright';


  /* Old File Upload Path  */
     
  // bill upload path 
 // private $bill_uploads = "/home/apache2438/htdocs/citizen_new/ctax/gstweb/uploads/bills";
  //private $bill_uploads_url = "https://rtionline.tn.gov.in/ctax/gstweb/uploads/bills";

  private $bill_uploads = "/home/apache2438/htdocs/citizen_new/ctax/gstweb/uploads";
  private $bill_uploads_url = "https://rtionline.tn.gov.in/ctax/gstweb/uploads";
  // log db path
  private $db_log_path =  "/home/apache2438/htdocs/citizen_new/ctax/gst/logs";
  //log path
  private $log_path =  "/home/apache2438/htdocs/citizen_new/ctax/gst/logs/log.txt";
// pgsql
  private $encrypt_private_key = "8/AaeB65F17A1c7f3F17A1c7NwewQ4f3";
  private $encrypt_secret_key = "WSa6qfh7RUGyph5j"; //  you can change this
  //private $response_type = "encrypted"; 
  //private $response_type = "plain"; 

  public function get($config_key)
  {
    return $this->$config_key;
  }
}
