<?php
namespace App\System\DB;


define("DB_DRIVER_MYSQL", "MYSQL");
define("DB_DRIVER_PGSQL", "PGSQL");



use Exception;
use App\System\Config;

class  DB
{
    private $driver;
    /**
     * query variables
     */
    private $query;
    private $where;
    protected $columns;
    protected $table;
    protected $primary_key;
    public $last_query = "";
    private $params;



    public function __construct($table_name = '', $primary_key_column = 'id')
    {
        // get table name and primary key column from construct
        $this->table = $table_name;
        $this->primary_key = $primary_key_column;
        $config   = new Config();
        $this->driver = $this->get_db_driver($config->get('db_driver'));
        $this->driver->connect(
            $config->get("db_host"),
            $config->get("db_port"),
            $config->get("db_name"),
            $config->get("db_user"),
            $config->get("db_password")

        );
        if (!$this->driver) {
            exit("Error : Unable to open database\n");
        }
        $this->query = "";
    }
    private function get_db_driver($driver)
    {
        $driver = strtoupper($driver);
        if ($driver == DB_DRIVER_MYSQL) {
            $driver_class_name = "\App\System\DB\Mysql";
        }
        if ($driver == DB_DRIVER_PGSQL) {
            $driver_class_name = "\App\System\DB\PgSql";
        }
        return new $driver_class_name();
    }
    private function build_where($where)
    {
        $where_array = [];
        // check where condains key value pair or array of conditions
        $key_count = count(array_keys($where));
        $value_count = count(array_values($where));
        if ($key_count == $value_count) {
            foreach ($where as $column => $condition) {
                $where_array[] = "$column = ?";
                $this->params[] = $condition;
            }
        } else {
            $where_array = $where;
        }
        $where_str = implode(" AND ", $where_array);
        return $where_str;
    }

    public function insert($data)
    {
        $this->params = [];
        $columns = $values = [];
        $values_string = null;
        foreach ($data as $column => $data) {
            $columns[] = $this->quote($column);
            $values[] = $this->safe_str($data);
            $values_string .= "?,";
        }
        $columns_string = implode(", ", $columns);

        // exit;
        $values_string = implode(", ", $values);
        $this->query = "INSERT INTO {$this->table} ( $columns_string ) VALUES ( $values_string );";

        return $this->execute($this->query, $values);
    }
    private function quote($column)
    {

        $char = "";
        if ($this->driver == 'mysql') {
            $char = "``";
        }
        if ($this->driver == 'pgsql') {
        }
        return $char . $column . $char;
    }
    private function  safe_str($value)
    {
        return $this->driver->escape($this->$value);
    }
    public function set_query($query)
    {
        $this->query = $query;
        return $this;
    }
    public function execute($sql, $placeholder = null)
    {
        $this->last_query  = $sql;

        $result = $this->driver->execute($sql, $placeholder);

        return $result;
    }
    protected function fetch($result, $type = null)
    {
        return $this->driver->fetch($result, $type);
    }
    /**
     * crud operations
     */
    public function select($columns = "*")
    {
        $this->params = [];
        $this->query = "SELECT " . $columns;
        return $this;
    }
    public function from($table = "")
    {
        if ($table == "") {
            exit("The table should not be empty");
        }
        $this->query .= " FROM " . $table;
       //echo $this->query;
        return $this;
    }

    public function join($table = "",$condition,$method)
   {
       if ($table == "") {
           exit("The table should not be empty");
       }
       $this->query .= ' '.$method." ".$table." ON ".$condition;
     //echo $this->query;
       return $this;
   }


   public function like($column_name,$condition)
   {
       $this->query .= "AND " .$column_name." LIKE "."'%$condition%'";
       //echo   $this->query;
       return $this;
   }

   public function wherelike($str,$condition)
   {
    
      
       $this->query .= " WHERE  " .$str." LIKE "."'%$condition%'";
      // echo   $this->query;
       return $this;
   }

   public function wherecondition($str)
   {
    
      
    $this->query .= " AND   $str";
      // echo   $this->query;
       return $this;
   }
    public function where($where = null)
    {

        $where_string = null;
        if (is_array($where)) {
            $where_string .= $this->build_where($where);
        } else {
            $where_string .= $where;
        }


        if ($where_string != null) {
            $this->query .= " WHERE " . $where_string;
        }
        echo $this->query;
        return $this;
    }
    public function orwhere($where = null)
    {

        $where_string = null;
        if (is_array($where)) {
            $where_string .= $this->build_where($where);
        } else {
            $where_string .= $where;
        }


        if ($where_string != null) {
            $this->query .= "  " . $where_string;
        }

       echo $this->query;
        return $this;
    }
    public function limit($rows_per_page, $page_no = null)
    {
       // $page_no  = ((int)$page_no  == 0) ? 1 : $page_no;
       // $starting_index = ($page_no - 1) * $rows_per_page;
        $this->query .= " LIMIT $rows_per_page, $page_no";

        echo $this->query;
        return $this;
    }
    public function where_in($column_name,$data)
    {

        $columns_string = "'" . implode ( "', '", $data ) . "'";
       
        $this->query .= " AND ". $column_name ." IN( $columns_string)" ;

       // echo $this->query;
      
        return $this;
    }


    public function order_by($order_by)
    {
        $this->query .= " ORDER BY $order_by";

       // echo $this->query;
       // exit;
      
        return $this;
    }
    public function get_list($rows_per_page = "all", $page_no = 1, $result_type = null)
    {
		
        if ($rows_per_page != "all") {
            $this->limit($rows_per_page, $page_no);
        }

        $result = $this->execute($this->query, $this->params);

        
        return $this->driver->fetchAll();
    }
    public function get_one($result_type = null)
    {
        $result = $this->execute($this->query);
        return $this->fetch($result, $result_type);
    }
    public function update($data, $where = null)
    {
        $this->params = [];
        $this->query = "UPDATE " . $this->table . " SET ";
        foreach ($data as $column => $value) {
            $this->query .= $this->quote($column) . "=?, ";
            $placeholders[] = $this->safe_str($value);
        }
        $this->query = substr($this->query, 0, -2);
  

        $where_str = null;
        if ($where ==  null) {
            $where_str = $this->where;
        } else if (is_array($where)) {
            
            $tmp_where_array = [];
            foreach( $where as $key => $value ){
                $tmp_where_array[] = $this->quote($key) . " = ?";
                $placeholders[] = $value;
            }
            $where_str = " WHERE " . implode(" AND ", $tmp_where_array);

        } else {
            $where_str =  " WHERE " . $where;
        }
        if ($where_str != null) {
            $this->query  .= $where_str;
            return $this->execute($this->query, $placeholders);
        } else {
            return false;
        }
    }

// Update Raw Query

public function updateRawQuery($tableName,$data, $where = null)
{
    $this->query = "UPDATE " . $tableName . " SET ";
    foreach ($data as $column => $value) {
        $this->query .= $this->quote($column) . "=" . $this->safe_str($value) . ", ";
    }
    $this->query = substr($this->query, 0, -2);

    $where_str = null;
    if ($where ==  null) {
        $where_str = $this->where;
    } else if (is_array($where)) {
        $where_str = " WHERE " . $this->build_where($where);
    } else {
        $where_str =  " WHERE " . $where;
    }
    if ($where_str != null) {
        $this->query  .= $where_str;
        return $this->execute($this->query);
    } else {
        return false;
    }
}
// Update Raw Query
    public function delete($id = 0)
    {
        $where_str = null;
        if ($id == 0 || $id == null) {
            $where_str = $this->where;
        } else {
            $where_str =  "WHERE {$this->primary_key} = $id";
        }


        if ($where_str != null) {
            $this->query  = "DELETE FROM {$this->table} {$where_str}";

            //echo $this->query  ;
           // exit;
            return $this->execute($this->query);
        } else {
            return false;
        }
    }
}

// class DB {
//     private static $db;
//     private final function __construct() {
//         echo __CLASS__ . " initialize only once ";
//     }
     
//     static function getInstance(): PDO{
//         $class = static::class;
//         if( !isset(self::$db)){
//             global $db;
//             self::$db = $db;
//         }

//         return self::$db;
//     }

//     // destroy 
//     static function destroy(){
//         global $db;
//         $db = null;
//         self::$db = null;
//     }
// }
