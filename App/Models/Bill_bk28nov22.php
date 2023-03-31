<?php
namespace App\Models;
/**
 * User model
 */
class Bill extends BaseModel {
    protected $table_name = 'mybillmyright.billdetail';
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
   
    public function getInvoices( $q = null , $userId ){


        //sleep(5);
        $table_name = $this->table_name;//for mysql
        $condition = null;
        $params = [];
        if( $q != null ){
            $condition .= "WHERE userid= ? and billdate >= date_trunc('month', CURRENT_DATE) and shopname ILIKE ? OR mobilenumber ILIKE ? ";
            //$params = ["%$q%", "%$q%"]; // full search 
            $params = [$userId ,"$q%", "$q%"]; // partial search 1
        }
        else{
            $condition .= "WHERE userid= ? and billdate >= date_trunc('month', CURRENT_DATE) ";
            //$params = ["%$q%", "%$q%"]; // full search 
            $params = [$userId]; // partial search 1

        }
      

        // return $this->query( "SELECT * FROM $table_name $condition", $params );
        // bill image url
        $config = new \App\System\Config();
        $bill_uploads_url = $config->get("bill_uploads_url");
        
        $bill_image_url_query = "(case 
        when bd.filepath != '' then concat('{$bill_uploads_url}/', bd.filepath) 
        when bd.filepath is null then '-'
        end ) as bill_image_url, ";

         return $this->query( "SELECT bd.*, INITCAP(bd.shopname) as shopname,  {$bill_image_url_query} md.distename as districtname 
         FROM $table_name
          as bd
         INNER JOIN mybillmyright.mst_district
          as md
         ON bd.distcode = md.distcode $condition order by bd.billdate desc", $params );
    }





    public function getInvoicesHistory( $q = null , $userId ){


        //sleep(5);
        $table_name = $this->table_name;//for mysql
        $condition = null;
        $params = [];
        if( $q != null ){
            $condition .= "WHERE userid= ? and billdate >= date_trunc('month', current_date - interval '3' month)
  and billdate < date_trunc('month', current_date) and shopname ILIKE ? OR mobilenumber ILIKE ? ";
            //$params = ["%$q%", "%$q%"]; // full search 
            $params = [$userId ,"$q%", "$q%"]; // partial search 1
        }
        else{
            $condition .= "WHERE userid= ? and billdate >= date_trunc('month', current_date - interval '3' month)
  and billdate < date_trunc('month', current_date) ";
            //$params = ["%$q%", "%$q%"]; // full search 
            $params = [$userId]; // partial search 1

        }
      

        // return $this->query( "SELECT * FROM $table_name $condition", $params );
        // bill image url
        $config = new \App\System\Config();
        $bill_uploads_url = $config->get("bill_uploads_url");
        
        $bill_image_url_query = "(case 
        when bd.filepath != '' then concat('{$bill_uploads_url}/', bd.filepath) 
        when bd.filepath is null then '-'
        end ) as bill_image_url, ";

         return $this->query( "SELECT bd.*, INITCAP(bd.shopname) as shopname,  {$bill_image_url_query} md.distename as districtname 
         FROM $table_name
          as bd
         INNER JOIN mybillmyright.mst_district
          as md
         ON bd.distcode = md.distcode $condition order by bd.billdate desc", $params );
    }
















    
     /**
     * get districts under the state
     * @todo: I think this method doesnot needed, we can use the District model, lets use it and remove it later if its really not needed
     */
    public function getAwkNumber( $distcode){

     
        return $this->row( "SELECT mc.yymm as yearmonth ,mu.deviceid as deviceid ,mc.distcode as distcode 
        FROM mybillmyright.mst_config as mc
        INNER JOIN mybillmyright.mst_user as mu
        ON mc.distcode = mu.distcode where mc.distcode = ?", [$distcode]);
    }

     /**
     * update Bill Table's Status Flag 
     */
    public function updateBillNumberStatusFlag($billId){
          return $this->query( "UPDATE  $this->table_name  SET statusflag = ? WHERE billdetailid = ?", [ 1,$billId]);
      }
}