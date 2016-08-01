<?php

namespace Zhandlersocket;

/**
 * Created by PhpStorm.
 * User: vbolshov <bolshov@tradetracker.com>
 * Date: 5-10-15
 * Time: 20:47
 */

class IndexTest extends BaseTest
{
    function testInsert() {
        $index = $this->createIndex($this->createClient());
        $this->assertInsert($index, ["id" => null, "title" => "Star wars", "view_count" => 0, "genre" => "Sci-Fi"]);
    }

    function testFindSingleRow() {
        $index = $this->createIndex($this->createClient());
        $id = $this->assertInsert($index, ["id" => null, "genre" => "Sci-Fi", "title" => "Star wars", "view_count" => 0]);
        $expected = ["id" => $id, "genre" => "Sci-Fi", "title" => "Star wars", "view_count" => 0];

        $row = $index->find($id);
        $this->assertEquals($expected, $row);
    }

    function testFindManyRows() {
        $index = $this->createIndex($this->createClient());
        $id1 = $this->assertInsert($index, ["id" => null, "genre" => "Sci-Fi", "title" => "Star wars", "view_count" => 0]);
        $id2 = $this->assertInsert($index, ["id" => null, "genre" => "Comedy", "title" => "Dumb & Dumber", "view_count" => 0]);

        $rows = $index->findMany([$id1, $id2]);
        $map = array_combine(
            array_column($rows, "id"),
            $rows
        );
        $this->assertEquals(
            [
                $id1 => ["id" => $id1, "genre" => "Sci-Fi", "title" => "Star wars", "view_count" => 0],
                $id2 => ["id" => $id2, "genre" => "Comedy", "title" => "Dumb & Dumber", "view_count" => 0],
            ],
            $map
        );
    }

    function testFindByWhereClause() {
        $index = $this->createIndex($this->createClient());
        $id1 = $this->assertInsert($index, ["id" => null, "genre" => "Sci-Fi", "title" => "Star wars", "view_count" => 0]);
        $id2 = $this->assertInsert($index, ["id" => null, "genre" => "Comedy", "title" => "Dumb & Dumber", "view_count" => 0]);

        $wc = $index->createWhereClause(WhereClause::GT, [0])->setLimit(10);
        $rows = $index->findByWhereClause($wc);

        $ids = array_column($rows, "id");
        $this->assertEquals(2, count($rows));
        $this->assertTrue(false !== array_search($id1, $ids));
        $this->assertTrue(false !== array_search($id2, $ids));

        $wc = $index->createWhereClause(WhereClause::GT, [0])->setLimit(10)->addFilter(WhereClause::EQ, "genre", "Comedy");
        $rows = $index->findByWhereClause($wc);
        $ids = array_column($rows, "id");
        $this->assertEquals(1, count($rows));
        $this->assertTrue(false !== array_search($id2, $ids));
    }

    function testUpdateById() {
        $index = $this->createIndex($this->createClient());
        $id = $this->assertInsert($index, ["id" => null, "genre" => "Sci-Fi", "title" => "Star wars", "view_count" => 0]);
        $this->assertTrue($index->updateById($id, ["id" => $id, "genre" => "Sci-Fi", "title" => "Star wars", "view_count" => 100]));

        $row = $index->find($id);
        $this->assertEquals($id, $row["id"]);
        $this->assertEquals(100, $row["view_count"]);
    }

    function testUpdateByWhereClause() {
        $index = $this->createIndex($this->createClient());

        $id1 = $this->assertInsert($index, ["id" => null, "genre" => "Sci-Fi", "title" => "Star wars", "view_count" => 0]);
        $id2 = $this->assertInsert($index, ["id" => null, "genre" => "Comedy", "title" => "Dumb & Dumber", "view_count" => 0]);

        $wc = $index->createWhereClause(WhereClause::GT, [0])->addFilter(WhereClause::EQ, "genre", "Comedy");
        $this->assertTrue($index->updateByWhereClause($wc, ["id" => $id2, "genre" => "Comedy", "title" => "Dumb & Dumber", "view_count" => 100]));

        $row = $index->find($id2);
        $this->assertEquals($id2, $row["id"]);
        $this->assertEquals(100, $row["view_count"]);
    }

    function testIncrementById() {
        $index = $this->createIndex($this->createClient());
        $id = $this->assertInsert($index, ["id" => null, "genre" => "Sci-Fi", "title" => "Star wars", "view_count" => 10]);
        $this->assertTrue($index->incrementById($id, ["id" => 0, "view_count" => 10]));

        $row = $index->find($id);
        $this->assertEquals($id, $row["id"]);
        $this->assertEquals(20, $row["view_count"]);
    }

    function testIncrementByWhereClause() {
        $client = $this->createClient();
        $index = $this->createIndex($client);

        $id1 = $this->assertInsert($index, ["id" => null, "genre" => "Sci-Fi", "title" => "Star wars", "view_count" => 10]);
        $id2 = $this->assertInsert($index, ["id" => null, "genre" => "Comedy", "title" => "Dumb & Dumber", "view_count" => 20]);

        $wc = $index->createWhereClause(WhereClause::GT, [0])->addFilter(WhereClause::EQ, "genre", "Comedy");
        $this->assertTrue($index->incrementByWhereClause($wc, ["id" => 0, "view_count" => 10]));

        $row = $index->find($id1);
        $this->assertEquals($id1, $row["id"]);
        $this->assertEquals(10, $row["view_count"]);

        $row = $index->find($id2);
        $this->assertEquals($id2, $row["id"]);
        $this->assertEquals(30, $row["view_count"]);
    }

    function testDeleteById() {
        $index = $this->createIndex($this->createClient());
        $id = $this->assertInsert($index, ["id" => null, "genre" => "Sci-Fi", "title" => "Star wars", "view_count" => 0]);
        $this->assertTrue($index->deleteById($id));

        $row = $index->find($id);
        $this->assertFalse($row);
    }

    function testDeleteByWhereClause() {
        $client = $this->createClient();
        $index = $this->createIndex($client);

        $id1 = $this->assertInsert($index, ["id" => null, "genre" => "Sci-Fi", "title" => "Star wars", "view_count" => 0]);
        $id2 = $this->assertInsert($index, ["id" => null, "genre" => "Comedy", "title" => "Dumb & Dumber", "view_count" => 0]);

        $wc = $index->createWhereClause(WhereClause::GT, [0])->addFilter(WhereClause::EQ, "genre", "Comedy");
        $this->assertTrue($index->deleteByWhereClause($wc));

        $row = $index->find($id2);
        $this->assertFalse($row);

        $row = $index->find($id1);
        $this->assertEquals($id1, $row["id"]);
    }

    private function assertInsert(Index $index, array $values) {
        $insertId = $index->insert($values);
        $this->assertTrue(is_numeric($insertId));
        $this->assertGreaterThan(0, $insertId);
        return $insertId;
    }
}