<?php
/**
 * Created by PhpStorm.
 * User: vbolshov <bolshov@tradetracker.com>
 * Date: 5-10-15
 * Time: 20:41
 */

dl("zhandlersocket.so");

define("ZHS_TABLE_MOVIE", "zhandlersocket_movie");

$connectionParams = include __DIR__ . "/connect.php";
define("ZHS_PORT_READ", $connectionParams["port_read"]);
define("ZHS_PORT_WRITE", $connectionParams["port_write"]);
define("ZHS_DSN", $connectionParams["dsn"]);
define("ZHS_USER", $connectionParams["user"]);
define("ZHS_PASSWORD", $connectionParams["password"]);
unset($connectionParams);

require_once __DIR__ . "/BaseTest.php";
\Zhandlersocket\BaseTest::setupTable();