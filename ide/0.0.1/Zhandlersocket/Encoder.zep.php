<?php

namespace Zhandlersocket;

/**
 * Because HS uses a simple text protocol, certain characters need to be encoded when sent to server and decoded back where sent back
 */
class Encoder
{

    const SHIFT = 0x40;


    const PREFIX = 0x01;


    static private $map = null;


    static private $rMap = null;


    /**
     * Encode string for HS protocol
     *
     * @param string $data 
     * @return string|int 
     */
    public static function encode($data) {}

    /**
     * @param mixed $data 
     * @return string|null 
     */
    public static function decode($data) {}

    /**
     * @return array 
     */
    private static function map() {}

    /**
     * @return array 
     */
    private static function rMap() {}

}
