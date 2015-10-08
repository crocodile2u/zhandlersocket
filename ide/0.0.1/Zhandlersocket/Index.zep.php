<?php

namespace Zhandlersocket;

/**
 * HS Index encapsulation
 */
class Index
{

    static private $next = 1;


    protected $client;


    protected $dbname;


    protected $table;


    protected $idx;


    protected $cols;


    protected $fcols = array();


    protected $num;


    protected $readIndexOpen = false;


    protected $writeIndexOpen = false;



    public function getClient() {}


    public function getDbname() {}


    public function getTable() {}


    public function getIdx() {}


    public function getCols() {}


    public function getFcols() {}


    public function getNum() {}

    /**
     * Constructor. Set up index params.
     *
     * @param mixed $client 
     * @param string $dbname 
     * @param string $table 
     * @param string $idx 
     * @param array $cols 
     * @param mixed $fcols 
     */
    protected function __construct(Client $client, $dbname, $table, $idx, $cols, $fcols = null) {}

    /**
     * @return string 
     */
    public function getColsAsString() {}

    /**
     * @param mixed $col 
     * @return int|bool 
     */
    public function getColumnIndex($col = null) {}

    /**
     * @return string 
     */
    public function getFcolsAsString() {}

    /**
     * @return bool 
     */
    public function hasFcols() {}

    /**
     * @param string $col 
     * @return int|bool 
     */
    public function getFcolumnIndex($col) {}

    /**
     * Insert a new row.
     * Depending on whether AUTO_INCREMENT is used, the return value differs:
     * - integer LAST INSERT ID for AUTO_INCREMENT mode;
     * - bool TRUE for NON-AUTO_INCREMENT mode.
     * For AUTO_INCREMENT mode, just pass NULL as the value for the AUTO_INCREMENT column
     *
     * @param array $values 
     * @return int|bool 
     */
    public function insert($values) {}

    /**
     * @param mixed $id 
     * @param mixed $values 
     */
    public function updateById($id, $values) {}

    /**
     * @param mixed $wc 
     * @param mixed $values 
     */
    public function updateByWhereClause(WhereClause $wc, $values) {}

    /**
     * @param mixed $id 
     * @param mixed $values 
     */
    public function incrementById($id, $values) {}

    /**
     * @param mixed $wc 
     * @param mixed $values 
     */
    public function incrementByWhereClause(WhereClause $wc, $values) {}

    /**
     * @param mixed $id 
     */
    public function deleteById($id) {}

    /**
     * @param mixed $wc 
     */
    public function deleteByWhereClause(WhereClause $wc) {}

    /**
     * @param mixed $values 
     */
    public function mapValues($values) {}

    /**
     * @param array $ids 
     * @param mixed $column 
     * @return array 
     */
    public function findMany($ids, $column = null) {}

    /**
     * @param string $op 
     * @param mixed $keyValues 
     * @return WhereClause 
     */
    public function createWhereClause($op, $keyValues) {}

    /**
     * @param mixed $wc 
     * @return array 
     */
    public function findByWhereClause(WhereClause $wc) {}

    /**
     * @param mixed $id 
     * @return array|bool 
     */
    public function find($id) {}

    /**
     * @param array $response 
     * @return array 
     */
    protected function parseFindResponse($response) {}

    /**
     * @param mixed $connection 
     */
    protected function open(Connection $connection) {}


    protected function ensureReadIndex() {}


    protected function ensureWriteIndex() {}

}
