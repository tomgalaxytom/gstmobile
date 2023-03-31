<?php
namespace App\Models;
/**
 * User model
 */
class State extends BaseModel {
    protected $table_name = 'mst_state';
    public function __construct()
    {
        parent::__construct($this->table_name);
    }
    /**
     * get States
     */
    public function getStates($columns = "*"){
       // echo  "SELECT * FROM `$this->table_name`";
        $table_name = $this->quote($this->table_name);
        return $this->query( "SELECT $columns FROM $table_name");
    }

    /**
     * get State
     */
    public function getState($stateid, $columns = "*"){
        return $this->row( "SELECT $columns FROM $this->table_name WHERE stateid = ?", [$stateid]);
    }
    /**
     * get districts under the state
     * @todo: I think this method doesnot needed, we can use the District model, lets use it and remove it later if its really not needed
     */
    public function getDistricts($statecode){
        echo "tobe deleted";
    }
}