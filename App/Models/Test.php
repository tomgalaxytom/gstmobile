<?php

namespace App\Models;

use App\Models\BaseModel;


class Test extends BaseModel
{
    protected $table_name = 'debarredliststbl';
    public function __construct()
    {
        parent::__construct('debarredliststbl', 'debarred_lists_id');
    }
    public function getDlists($parent_id = 0)
    {
        $data = $this->query("select * from $this->table_name where debarred_lists_id = ?", [40]);
        return $data;
    }
}

