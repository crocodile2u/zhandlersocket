# zhandlersocket
Another PHP extension for communicating with handlersocket. Built with Zephir: https://github.com/phalcon/zephir. Thus, you will have to install Zephir first to build zhandlersocket.
Once you have Zephir installed and cloned the zhandlersocket repo:
```bash
cd <zhandlersocket directory>
zephir build
```
After that, under _ext/modules_ you will find the zhandlersocket.so. Copy it to your PHP's extension_dir, add "extension=zhandlersocket.so" to your php.ini and restart your web-server. Check with the following command if zhandlersocket is there:
```bash
php -m
```
The output should, among other lines, contain "zhandlersocket".

## Short example

```php
use \Zhandlersocket\Client;

$client = new Client();// create a HS client with default connection parameters

$index = $client->getIndex("test", "my_table", "PRIMARY", ["id", "name"]);

// find() would return an array of rows, because an index is not always unique
// In this case, we know there will be 1 or 0 rows with ID=10, so we use findFirst(),
// which will fetch the very first row and return it
$row = $index->findFirst(10);

// Update a row:
$upd = $index->updateById(10, ["id" => 10, "name" => "New name"]);// have to specify ALL columns
```

## A closer look

HandlerSocket enables you to use InnoDB table in a NoSQL way. HS performance when selecting by Primary Key is at least close to that of Memcached, and according to some benchmarks, HS is even faster. Given this, you might well give up on using Memcached in certain cases (and having all the assiciated headaches with cache invalidating).

HS operates on InnoDB *indexes*. That means that you always perform a query on a index. This might be the table's PRIMARY KEY but it also may be any other index you have on the table.

In order to perform queries with ZhandlerSocket, you first need to instantiate *ZhandlerSocket\Client*:

```php
$client = new Client("localhost", 9998, 9999);
```

Above are the default connection parameters, and you could as well omit them.

When you have a Client instance, you might want to create an instance of *ZhandlerSocket\Index*:

```php
$index = $client->getIndex("test", "my_table", "PRIMARY", ["id", "name"]);
```

This code means that you would like to speak Handlersocket with InnoDB table **my_table** from database **test**. You will perform you *find* queries using *PRIMARY KEY*, and you would like to receive in response the foloowing columns: **id** and **name**.

*PRIMARY KEY* is not the only capability. Suppose you have a table **movie**, which has fields **id, genre, title, view_count**. *PRIMARY KEY* is **id** but there is also a key on **genre** column called *genre_key*. Eventually, the index might well be named exactly as the column but don't be confused: when opening a HS index, you need the **index name**, not the **column name**.

```php
$index = $client->getIndex("test", "movie", "genre_key", ["id", "genre", "title", "view_count"]);
```

*ZhandlerSocket\Client->getIndex()* method accepts an optional 5th parameter which is **filter columns**. This specifies columns that you want to support additional filtering for. Those do not necessarily have to be a part of index but they have to be a part of columns you chose for selection (4th argument).

Basic usage of HS is to select a row by key, update a row, delete a row. *ZhandlerSocket\Index* class has the following to offer for the basic find-by-key functionality:

* *find(id)* - return one row with matching id. An index might consist of several columns, and HS allows you to select rows by a compound key. For this, *find()* supports passing array as its argument. You have to take care that values in this array come in exactly the same order as they are mentioned in the InnoDB index. The return value is an associative array with keys matching to column names you specified when calling *ZhandlerSocket\Client->getIndex()*. In case no matching rows found, *find()* will return boolean *FALSE*;
* *findMany(array ids[, string column = null])* - an equivalent of SQL IN clause. Attempts to find all rows with IDs from from the first argument. The match is done against the very first column passed to *Client->getIndex()*.

However, *ZhandlerSocket\Index* has also more to offer. HandlerSocket provides one with robust tools for quickly finding rows in a InnoDB table. Zhandlersocket ships with *WhereClause* class which enables you to specify criteria you want to apply to the selection.

* *findByWhereClause()* - Zhandlersocket ships with a *Zhandlersocket\WhereClause* class which is capable of building the HS analogue of SQL WHERE and LIMIT clause together. You can create the *WhereClause* instance with *Index->createWhereClause()*, setup your filters and LIMIT/OFFSET, then either call *Index->findByWhereClause()* or simply do *WhereClause->find()* method (which is the preferable way).

## Manipulating data with *ZhandlerSocket\Index*:

* *insert(array values)* - insert a new row. Depending on whether AUTO_INCREMENT is used, the return value differs:
    - integer LAST INSERT ID for AUTO_INCREMENT mode;
    - bool TRUE for NON-AUTO_INCREMENT mode.
For AUTO_INCREMENT mode, simply pass NULL as the value for the AUTO_INCREMENT column
* *updateById(id, values)* - update row identified by ID. *values* is an assoc {col1: val1,..}, and all the values for all columns that you used creating the index, have to be specified.
* *updateByWhereClause(<WhereClause> wc, values)* - same as above but will update all the columns matching the *WhereClause*. Use with care and bear in mind the LIMIT that is set up in WhereClause and by default it applies a limit of 1 with offset 0, unless you have used *WhereClause->setIn()* or explicitly set limit with *WhereClause->setLimit()*.
* *incrementById(id, values)* - increment values in a row specified by ID. Internally, delegates to *incrementByWhereClause()*
* *incrementByWhereClause(<WhereClause> wc, values)* - increment values in rows that match to *WhereClause*. Use with care and bear in mind the LIMIT that is set up in WhereClause in values. You only specify those cols that need to be incremented + the ID column(s) Internally, a new index is created containing JUST the columns to be updated, because as a result of the increment request, all participating STRING cols will be updated to "0" if you leave them there. The implementation is quite poor and a very possible subject to change. However, it seems like the HS implementation of increment is poor either. Maybe I will just have to remove its support.
* *deleteById(id)* - delete a row by ID
* *function deleteByWhereClause(<WhereClause> wc)* - delete rows that match WhereClause. Use with care and bear in mind the LIMIT that is set up in WhereClause.

## *Zhandlersocket\WhereClause* short reference

*WhereClause* class is responsible for filtering and setting limits for selection from HS. HS is not only capable of selecting a single row by PRIMARY KEY, but also of selecting multiple rows based on criteria. 
Basic usage: 

```php
// We have an index on "counter" column, and we want to find up to 10 rows with counter > 20   
$index = $client->getIndex("test", "test", "counter_idx", ["id", "counter"]);
$rows = $index->createWhereClause(">", 20)->setLimit(10)->find();
```
You can also perform some filtering of the results with *WhereClause->addFilter()*. This is _post-filtering_ which occurs on the result set obtained from index. Filtering can be done on all columns specified as *fcols* argument whe creating the index.