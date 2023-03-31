<?php
namespace App\System;
/**
 * class file for managing logs
 */
class Log {
    public static function log($logMessage = null){
        $config = new \App\System\Config();
        $logFilePath = $config->get('log_path');
        if( $logFilePath == '' ){
            $logFilePath = realpath( __DIR__ . "/../log.txt");
        }
        // add the time and date
        // make ist time 
        $timezone = \date_default_timezone_get();
        date_default_timezone_set('Asia/Kolkata');
        $logMessage = "[" . date("Y-m-d H:i:s") . "] " . $logMessage;
        date_default_timezone_set($timezone);
        file_put_contents( $logFilePath, $logMessage . PHP_EOL, FILE_APPEND );
    }
    /**
     * Log errors
     *
     * @param string $logMessage
     * @return void
     */
    public static function error($logMessage = ''){
        self::log("Error: " . $logMessage);
    }
    /**
     * Log info
     *
     * @param string $logMessage
     * @return void
     */
    public static function info($logMessage = ''){
        self::log("Info: " . $logMessage);
    }

    /**
     * just to log query for debugging
     * @param string $method [insert, update]
     * @param string $tableName
     * @param array $data 
     * @param string $wherePrimarykey
     * @return void
     */
    public static function query($method, $tableName, $data, $wherePrimarykey = null ){
        $method = strtolower( $method );
        if( $method == 'insert'){
            $queryString =  'INSERT INTO ' . $tableName . ' (' . implode(',', array_keys($data)) . ') VALUES (' . '\'' . implode('\',\'', array_values($data)) . '\')';
        } else if( $method == 'update'){
            $queryString = "UPDATE {$tableName} SET ";
            foreach( $data as $key => $value ){
                $queryString .= "$key = '$value', ";
            }
            $queryString = substr( $queryString, 0, -2);
            if( $wherePrimarykey != null )
                $queryString .= " WHERE __PRIMARY_KEY__ = '$wherePrimarykey' ";
        } else {
            $queryString = "Method: $method, TableName: $tableName, Data: " . json_encode($data) . ", WHERE: $wherePrimarykey";
        }
        self::info( $queryString );
    }
}