<?php

namespace Zhandlersocket;


class WhereClause
{

    const EQ = "=";


    const GT = ">";


    const GTE = ">=";


    const LT = "<";


    const LTE = "<=";


    private $index;


    private $op;


    private $keyValues = array();


    private $limit = 1;


    private $offset = 0;


    private $inColumn;


    private $inValues = array();


    private $filters = array();


    /**
     * @param mixed $index 
     * @param string $op 
     * @param mixed $keyValues 
     */
    public function __construct(Index $index, $op, $keyValues) {}

    /**
     * @param int $limit 
     * @param int $offset 
     * @return WhereClause 
     */
    public function setLimit($limit, $offset = 0) {}

    /**
     * @param array $values 
     * @param mixed $column 
     * @return WhereClause 
     */
    public function setIn($values, $column = null) {}

    /**
     * @param string $op 
     * @param string $column 
     * @param mixed $value 
     * @param string $type 
     * @return WhereClause 
     */
    public function addFilter($op, $column, $value, $type = WhereClauseFilter::TYPE_FILTER) {}


    public function find() {}

    /**
     * @return array 
     */
    public function toArray() {}

}
