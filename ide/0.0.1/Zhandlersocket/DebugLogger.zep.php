<?php

namespace Zhandlersocket;

/**
 * A logger that is created when we are in debug mode
 */
class DebugLogger extends \Zhandlersocket\Logger
{

    private $messages = array();


    private $timers = array();


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

    /**
     * For whatever reason, I could not just do this simple math: microtime(true) - this->timers[label]
     * It always produces Zephir\CompilerException: Unknown type: sub
     *
     * @param double $v1 
     * @param double $v2 
     */
    private function sub($v1, $v2) {}

}
