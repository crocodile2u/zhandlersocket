<?php
/**
 * Created by PhpStorm.
 * User: vbolshov <bolshov@tradetracker.com>
 * Date: 5-10-15
 * Time: 20:42
 */

define("ZHS_HOST", "127.0.0.1");
define("ZHS_DBNAME", "test");

return [
    "dsn" => "mysql:host=" . ZHS_HOST . ";dbname=" . ZHS_DBNAME . ";",
    "user" => "root",
    "password" => "masha",
    "port_read" => 9998,
    "port_write" => 9999,
];