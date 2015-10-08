<?php

namespace Zhandlersocket;

/**
 * Hanslersocket connection encapsulation
 */
class Connection
{

    const DEFAULT_CONNECTION_TIMEOUT = 5;


    const DEFAULT_IO_TIMEOUT = 1.0;


    private $host;


    private $port;


    private $connectionTimeout = self::DEFAULT_CONNECTION_TIMEOUT;


    private $ioTimeout = self::DEFAULT_IO_TIMEOUT;


    private $persistent;


    private $connected = false;


    private $connResource;


    private $debugLog;


    /**
     * @param mixed $ioTimeout 
     */
    public function setIoTimeout($ioTimeout) {}

    /**
     * Constructor. Setup connection params, initialize Logger
     *
     * @param string $host 
     * @param int $port 
     * @param bool $persistent 
     */
    protected function __construct($host = "127.0.0.1", $port, $persistent = false) {}

    /**
     * Send a command and receive response.
     * Response is parsed, decoded and returned as array of strings
     *
     * @param string $cmd 
     */
    public function send($cmd) {}

    /**
     * @return array 
     */
    private function receiveLine() {}

    /**
     * @return bool 
     */
    public function connect() {}

    /**
     * @return bool 
     */
    public function disconnect() {}


    public function __destruct() {}

    /**
     * @param mixed $logger 
     */
    public function setDebugLog(Logger $logger) {}

    /**
     * @return Logger 
     */
    public function getDebugLog() {}

}
