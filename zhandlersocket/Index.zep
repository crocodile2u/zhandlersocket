namespace Zhandlersocket;

/**
 * HS Index encapsulation
 */

class Index {
    // @var int next created index number
    static private next = 1;
    // @var Client
    protected client {get};
    // @var string
    protected dbname {get};
    // @var string
    protected table {get};
    // @var string
    protected idx {get};
    // @var string[]
    protected cols {get};
    // @var string[] Filter columns
    protected fcols = [] {get};
    // @var int this instance index number
    protected num {get};
    // @var bool
    protected readIndexOpen = false;
    // @var bool
    protected writeIndexOpen = false;

    /**
     * Constructor. Set up index params.
     */
    protected function __construct(<Client> client, string dbname, string table, string idx, array cols, fcols = null) {
        let this->client = client;
        let this->dbname = dbname;
        let this->table = table;
        let this->idx = idx;
        let this->cols = cols;
        if fcols {
            let this->fcols = fcols;
        }
        let this->num = self::next;
        let self::next = self::next + 1;
    }

    public function getColsAsString() -> string {
        return join(",", this->cols);
    }

    public function getColumnIndex(col = null) -> int|bool {
        if null === col {
            return 0;
        } else {
            return array_search(col, this->cols);
        }
    }

    public function getFcolsAsString() -> string {
        return join(",", this->fcols);
    }

    public function hasFcols() -> bool {
        return count(this->fcols) > 0;
    }

    public function getFcolumnIndex(string col) -> int|bool {
        return array_search(col, this->fcols);
    }
    /**
     * Insert a new row.
     * Depending on whether AUTO_INCREMENT is used, the return value differs:
     * - integer LAST INSERT ID for AUTO_INCREMENT mode;
     * - bool TRUE for NON-AUTO_INCREMENT mode.
     * For AUTO_INCREMENT mode, just pass NULL as the value for the AUTO_INCREMENT column
     */
    public function insert(array values) -> int|bool {
        this->ensureWriteIndex();
        var connection = this->client->getWriteConnection();
        var response = connection->send(Command::insert(this, values));

        if response[0] == 1 && response[1] == 1 {
            throw new DuplicateEntryException();
        }

        if response[0] == 0 && response[1] == 1 {
            if (3 == count(response)) {
                return response[2];
            } else {
                return true;
            }
        } else {
            throw new CommunicationException("Failed inserting values in DB: " . join("\t", response));
        }
    }
    // update row identified by ID
    // values is an assoc [col1: val1,..]
    public function updateById(id, values) {
        var wc = this->createWhereClause(WhereClause::EQ, id);
        return this->updateByWhereClause(wc, values);
    }
    // Update rows that match to WhereClause. Use with care and bear in mind the LIMIT that is set up in WhereClause
    public function updateByWhereClause(<WhereClause> wc, values) {
        this->ensureWriteIndex();
        var connection = this->client->getWriteConnection();

        var response = connection->send(Command::update(this, wc, values));
        if response[0] == 0 {
            return true;
        } else {
            throw new CommunicationException("Failed updating values in DB: " . join("\t", response));
        }
    }
    // increment values in a row specified by ID
    public function incrementById(id, values) {
        var wc = this->createWhereClause(WhereClause::EQ, id);
        return this->incrementByWhereClause(wc, values);
    }
    // increment values in rows that match to WhereClause. Use with care and bear in mind the LIMIT that is set up in WhereClause
    // in values, you only specify thos cols that need to be incremented + the ID column(s)
    // Internally, a new index is created containing JUST the columns to be updated, because as a result of the increment request, all participating STRING cols
    // will be updated to "0" if you leave them there.
    // the implementation is quite poor and a very possible subject to change. However, it seems like the HS
    // implementation of increment is quite poor either. Maybe I will just have to remove its support
    public function incrementByWhereClause(<WhereClause> wc, values) {
        var incIndex;
        let incIndex = new Index(this->client, this->dbname, this->table, this->idx, array_keys(values), this->fcols);
        incIndex->ensureWriteIndex();
        var connection = this->client->getWriteConnection();

        var response = connection->send(Command::increment(incIndex, wc, values));
        if response[0] == 0 {
            return true;
        } else {
            throw new CommunicationException("Failed updating values in DB: " . join("\t", response));
        }
    }
    // delete a row by ID
    public function deleteById(id) {
        var wc = this->createWhereClause(WhereClause::EQ, id);
        return this->deleteByWhereClause(wc);
    }
    // delete rows that match WhereClause. Use with care and bear in mind the LIMIT that is set up in WhereClause
    public function deleteByWhereClause(<WhereClause> wc) {
        this->ensureWriteIndex();
        var connection = this->client->getWriteConnection();

        var response = connection->send(Command::delete(this, wc));
        if response[0] == 0 {
            return true;
        } else {
            throw new CommunicationException("Failed updating values in DB: " . join("\t", response));
        }
    }
    // make a numeric array out of assoc, in a way that will match the column numbers as they were passed to constructor
    public function mapValues(values) {
        var column, columnIndex, value, colValues = [];
        for column, value in values {
            if is_string(column) {
                let columnIndex = this->getColumnIndex(column);
                let colValues[columnIndex] = value;
            } else {
                let colValues[] = value;
            }
        }
        ksort(colValues);
        return colValues;
    }
    // find rows by a bunc of IDs (equivalent of SQL IN clause)
    public function findMany(array ids, column = null) -> array {
        return this->createWhereClause("=", [0])->setIn(ids, column)->find();
    }
    
    public function createWhereClause(string op, keyValues) -> <WhereClause> {
        return new WhereClause(this, op, keyValues);
    }

    public function findByWhereClause(<WhereClause> wc) -> array {
        this->ensureReadIndex();
        var connection = this->client->getReadConnection();
        var tokens = wc->toArray();
        array_unshift(tokens, this->getNum());
        //var_dump(tokens);
        var cmd = Command::compose(tokens);
        var response = connection->send(cmd);
        var rows = this->parseFindResponse(response);
        return rows;
    }

    public function find(id) -> array {
        return this->createWhereClause("=", [id])->find();
    }

    public function findFirst(id) -> array|bool {
        var rows = this->find(id);
        if rows {
            return rows[0];
        } else {
            return false;
        }
    }

    protected function parseFindResponse(array response) -> array {
        if (0 != array_shift(response)) {
            throw new CommunicationException("find() returns an error");
        }
        var numColumns = array_shift(response);
        var ret = [];
        var chunk;
        for chunk in array_chunk(response, numColumns) {
            let ret[] = array_combine(this->cols, chunk);
        }
        return ret;
    }

    protected function open(<Connection> connection) {
        var response = connection->send(Command::open(this));
        if response[0] != 0 || response[1] != 1 {
            throw new CommunicationException("Failed opening index");
        }
    }

    protected function ensureReadIndex() {
        if (!this->readIndexOpen) {
            if this->writeIndexOpen {
                let this->readIndexOpen = true;
                return ;
            }
            this->open(this->client->getReadConnection());
            let this->readIndexOpen = true;
        }
    }

    protected function ensureWriteIndex() {
        if (!this->writeIndexOpen) {
            this->open(this->client->getWriteConnection());
            let this->writeIndexOpen = true;
        }
    }
}