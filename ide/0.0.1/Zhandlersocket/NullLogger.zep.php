<?php

namespace Zhandlersocket;


class NullLogger extends \Zhandlersocket\Logger
{

    /**
     * @param string $message 
     */
    public function write($message) {}

    /**
     * @param string $label 
     */
    public function timerStart($label) {}

    /**
     * @param string $label 
     */
    public function timerEnd($label) {}

    /**
     * @return array 
     */
    public function export() {}

}
