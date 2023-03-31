<?php
namespace App\Models;
use App\System\PDO\DB;
class BaseModel extends DB {

    // get quote
    public function quote($str){
        $config   = new \App\System\Config();
		$db_driver = $config->get("db_driver");
        if( $db_driver = "mysql"){
            return $str = "`$str`";
        } else {
            return $str;
        }
    }
}
