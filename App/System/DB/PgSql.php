<?php
/**
 * postgre sql driver 
 */
namespace App\System\DB;

use App\System\DB\Base;

class PgSql implements Base
{
    
    public $conn;
    public $db;
    private $stmt;

    public function __construct()
    {
    } //

    public function connect($host, $port, $db, $user, $password)
    {
        $dsn =  "pgsql:host=$host;port=$port;dbname=$db;";
        $pdo = new \PDO($dsn, $user, $password) or die('Connection error'); 
        $this->db  = $pdo;
        // echo $connection_string;
        // $this->conn = pg_connect($connection_string);
    }
    public function execute($sql, $placeholder = null)
    {
        if( $placeholder ){
            $stmt = $this->db->prepare( $sql );            
            $stmt->execute( $placeholder);
        } else {
            $stmt = $this->db->query( $sql );
        }
        $this->stmt = $stmt;
        return $stmt;	
    }
    public function fetch($type){
        return $this->stmt->fetch($type);
    }
    public function fetchAll($type = \PDO::FETCH_OBJ){
        return $this->stmt->fetchAll($type);
    }
}
