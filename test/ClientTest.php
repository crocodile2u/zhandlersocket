<?php

namespace Zhandlersocket;

require_once __DIR__ . "/BaseTest.php";

/**
 * Created by PhpStorm.
 * User: vbolshov <bolshov@tradetracker.com>
 * Date: 5-10-15
 * Time: 20:47
 */

class ClientTest extends BaseTest
{
    function testGetIndex() {
        $client = $this->createClient();
        $index1 = $client->getIndex("db", "table", "PRIMARY", ["id", "name"], ["name"]);
        $this->assertEquals(1, $client->getIndexCount());

        // should be the same instance as index1
        $index2 = $client->getIndex("db", "table", "PRIMARY", ["id", "name"], ["name"]);
        $this->assertEquals(1, $client->getIndexCount());
        $this->assertEquals($index1, $index2);

        // definition differs, so it must be a different instance
        $index3 = $client->getIndex("db", "table", "PRIMARY", ["id", "name"]);
        $this->assertEquals(2, $client->getIndexCount());
        $this->assertNotEquals($index3, $index2);
    }

    function testGetReadConnection() {
        $client = $this->createClient();
        $rc1 = $client->getReadConnection();
        $this->assertInstanceOf(Connection::class, $rc1);

        $rc2 = $client->getReadConnection();
        $this->assertInstanceOf(Connection::class, $rc2);
        $this->assertEquals($rc1, $rc2);

        $client = $this->createClient();
        $wc = $client->getWriteConnection();
        $this->assertInstanceOf(Connection::class, $wc);

        $rc3 = $client->getReadConnection();
        $this->assertInstanceOf(Connection::class, $rc3);
        $this->assertEquals($wc, $rc3);// client already established write connection, it should be reused
    }

    function testGetWriteConnection() {
        $client = $this->createClient();
        $wc1 = $client->getWriteConnection();
        $this->assertInstanceOf(Connection::class, $wc1);

        $wc2 = $client->getWriteConnection();
        $this->assertInstanceOf(Connection::class, $wc2);
        $this->assertEquals($wc1, $wc2);
    }
}