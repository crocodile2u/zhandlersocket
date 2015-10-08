<?php

namespace Zhandlersocket;

/**
 * Client class. Holds read/write connections (caches the connections internally);
 * responsible for creating Index instances;
 *
 * @package Zhandlersocket
 * @author Victor Bolshov <crocodile2u@gmail.com>
 */
class Client
{

    private $host;


    private $portRead;


    private $portWrite;


    private $indexes = array();


    private $readConnection;


    private $writeConnection;


    private $usePersistentConnection = true;


    private $enableDebug = false;



    public function getUsePersistentConnection() {}

    /**
     * @param mixed $usePersistentConnection 
     */
    public function setUsePersistentConnection($usePersistentConnection) {}

    /**
     * Constructor. Setup connection parameters.
     * Connection is not established here, this is done only when we need to issue a request
     *
     * @param string $host 
     * @param int $portRead 
     * @param int $portWrite 
     */
    public function __construct($host = "127.0.0.1", $portRead = 9998, $portWrite = 9999) {}

    /**
     * get create indexes count
     *
     * @return int 
     */
    public function getIndexCount() {}

    /**
     * Get a index from a pool or create a new one and put it into the pool
     *
     * @param string $dbname 
     * @param string $table 
     * @param string $idx 
     * @param array $cols 
     * @param mixed $fcols 
     * @return Index 
     */
    public function getIndex($dbname, $table, $idx, $cols, $fcols = null) {}

    /**
     * @return Connection 
     */
    public function getReadConnection() {}

    /**
     * @return Connection 
     */
    public function getWriteConnection() {}

    /**
     * Enables or disables debug logging (disabled by default).
     * When enabled, debug informarion will be collected and you will be able to get it later with getDebugLog()
     *
     * @param bool $flag 
     */
    public function setEnableDebug($flag) {}

    /**
     * Get the debug log
     *
     * @return Log 
     */
    public function getDebugLog() {}

}
