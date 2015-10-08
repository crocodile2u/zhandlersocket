<?php

namespace Zhandlersocket;


abstract class Logger
{

    /**
     * @param bool $debug 
     */
    static public function create($debug) {}

    /**
     * @param string $message 
     */
    public abstract function write($message);

    /**
     * @param string $label 
     */
    public abstract function timerStart($label);

    /**
     * @param string $label 
     */
    public abstract function timerEnd($label);

    /**
     * @return array 
     */
    public abstract function export();

}
