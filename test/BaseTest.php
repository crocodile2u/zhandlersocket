<?php
namespace Zhandlersocket;
/**
 * Created by PhpStorm.
 * User: vbolshov <bolshov@tradetracker.com>
 * Date: 5-10-15
 * Time: 22:27
 */
class BaseTest extends \PHPUnit_Framework_TestCase
{
    /**
     * @var \PDO
     */
    static $pdo;
    protected function createClient() {
        $ret = new Client(ZHS_HOST, ZHS_PORT_READ, ZHS_PORT_WRITE);
        $ret->setEnableDebug(true);
        return $ret;
    }
    protected function createIndex(Client $client) {
        return $client->getIndex(ZHS_DBNAME, ZHS_TABLE_MOVIE, "PRIMARY", ["id", "genre", "title", "view_count"], ["genre"]);
    }
    public function setUp() {
        self::pdo()->exec("DELETE FROM " . ZHS_TABLE_MOVIE);
    }
    static public function setupTable() {
        self::pdo()->exec("DROP TABLE IF EXISTS " . ZHS_TABLE_MOVIE);
        self::pdo()->exec("CREATE TABLE " . ZHS_TABLE_MOVIE . "
            (
                id int not null auto_increment PRIMARY KEY,
                genre VARCHAR(20) NOT NULL,
                title varchar(100) NOT NULL,
                view_count INT NOT NULL DEFAULT 0,
                KEY(genre)
            ) ENGINE InnoDB");
    }
    static public function pdo() {
        if (self::$pdo) {
            return self::$pdo;
        } else {
            return self::$pdo = new \PDO(ZHS_DSN, ZHS_USER, ZHS_PASSWORD);
        }
    }
}