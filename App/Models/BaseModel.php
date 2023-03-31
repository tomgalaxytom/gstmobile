<?php
namespace App\Models;
use App\System\PDO\DB;
class BaseModel extends DB {
    protected $db_prefix = "";
    protected $table_name;
    public function __construct( $table_name)
    {
        parent::__construct();
        $this->table_name = $this->getPrefixedTableName($table_name); 
    }
    /**
     * get prefixed table for schema 
     *
     * @param string $tableName
     * @return string $tableName;
     */
    public function getPrefixedTableName($tableName){
        $config   = new \App\System\Config();
        $db_driver = $config->get("db_driver");
        if( $db_driver == "pgsql"){
            $this->db_prefix = $config->get('db_schema') . ".";
            $table_with_prefix = $this->db_prefix . $tableName;
            if( stripos($tableName, $this->db_prefix) === false ){
                $tableName  = $table_with_prefix;
            }
        }
        return $tableName;
    }
    // get quote
    public function quote($str){
        $config   = new \App\System\Config();
        $db_driver = $config->get("db_driver");
        if( $db_driver == "mysql"){
            return $str = "`$str`";
        } else {
            return $str;
        }
    }
}
