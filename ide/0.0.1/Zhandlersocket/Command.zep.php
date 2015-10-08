<?php

namespace Zhandlersocket;

/**
 * A simple collection of static methods to compose HS commands
 */
class Command
{

    const DELIMITER = "\\t";


    /**
     * compose open_index command
     *
     * @param mixed $index 
     * @return string 
     */
    static public function open(Index $index) {}

    /**
     * compose insert command
     *
     * @param mixed $index 
     * @param mixed $values 
     * @return string 
     */
    static public function insert(Index $index, $values) {}

    /**
     * compose update command
     *
     * @param mixed $index 
     * @param mixed $wc 
     * @param mixed $values 
     * @return string 
     */
    static public function update(Index $index, WhereClause $wc, $values) {}

    /**
     * compose increment command
     *
     * @param mixed $index 
     * @param mixed $wc 
     * @param mixed $values 
     * @return string 
     */
    static public function increment(Index $index, WhereClause $wc, $values) {}

    /**
     * compose delete command
     *
     * @param mixed $index 
     * @param mixed $wc 
     * @return string 
     */
    static public function delete(Index $index, WhereClause $wc) {}

    /**
     * encode command tokens and compose a string
     *
     * @param array $tokens 
     * @return string 
     */
    static public function encode($tokens) {}

    /**
     * encode command tokens and compose a string
     *
     * @param string $line 
     * @return array 
     */
    static public function decode($line) {}

    /**
     * compose a command
     *
     * @param array $tokens 
     * @return string 
     */
    static public function compose($tokens) {}

}
