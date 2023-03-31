<?php
namespace App\Models;
/**
 * User model
 */
class District extends BaseModel {
    protected $table_name = 'mst_district';
    protected $table_config_name = "mst_config";
    public function __construct()
    {
        parent::__construct($this->table_name);
        $this->table_config_name = $this->getPrefixedTableName( $this->table_config_name );
    }
     /**
     * get Districts
     */
    public function getDistricts(){
         //$table_name = $this->quote($this->table_name);//for mysql
         $table_name = $this->table_name;//for mysql
         return $this->query( "SELECT * FROM $table_name");
     }
    /**
     * get district by id
     */
    
    public function getDistrict($distid, $columns = "*"){
        return $this->row( "SELECT $columns FROM $this->table_name WHERE distid = ?", [$distid]);
    }
    public function getDistrictByStateCode($statecode, $config = false, $columns = "*") {

       


        $table_name =$this->table_name;
        $where = null;
        if( $config ){
            $where = " WHERE distcode IN(SELECT distcode FROM $this->table_config_name)";
        }
        //echo "SELECT $columns FROM $table_name  $where order by distename";
       // exit;

        return $this->query( "SELECT $columns FROM $table_name  $where order by distename");
    }

}