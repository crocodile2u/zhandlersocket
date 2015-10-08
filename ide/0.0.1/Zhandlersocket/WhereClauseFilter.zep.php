<?php

namespace Zhandlersocket;


class WhereClauseFilter
{

    const TYPE_FILTER = "F";


    const TYPE_WHILE = "W";


    private $type;


    private $op;


    private $column;


    private $value;


    /**
     * @param string $op 
     * @param int $column 
     * @param mixed $value 
     * @param string $type 
     */
    public function __construct($op, $column, $value, $type = self::TYPE_FILTER) {}


    public function toArray() {}

}
