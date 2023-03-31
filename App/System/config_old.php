<?php
namespace App\System;

class Config
{
  private $db_driver = "mysql";
  private $db_host = "localhost";
  private $db_port = "3306";
  private $db_name = "codelooms34_krnaturelive";
  private $db_user = "codelooms34_krnaturelive";
  private $db_password = '2e5$iA|b"COk>30j';

/**
 * pgsql
 *  
  private $db_driver = "pgsql";
  private $db_host = "localhost";
  private $db_port = "5432";
  private $db_name = "tax";
  private $db_user = "postgres";
  private $db_password = 'stalinthomas';
 * 
 * 
 */
  public function get($config_key)
  {
    return $this->$config_key;
  }
}
