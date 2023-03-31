<?php

/**
 * db base class
 * 
 */

namespace App\System\DB;

interface  Base
{
    /*protected $host;
    protected $port;
    protected $db;
    protected $access_details;
    */
    public function connect($host, $port, $db, $user, $password);

    public function fetch($type);

    public function execute($sql);

}