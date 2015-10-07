namespace Zhandlersocket;

class Index {
    static private next = 1;
    protected client {get};
    protected dbname {get};
    protected table {get};
    protected idx {get};
    protected cols {get};
    protected fcols = [] {get};
    protected num {
        get
    };
    protected readIndexOpen = false;
    protected writeIndexOpen = false;

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

    public function insert(array values) {
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

    public function updateById(id, values) {
        var wc = this->createWhereClause(WhereClause::EQ, id);
        return this->updateByWhereClause(wc, values);
    }

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

    public function incrementById(id, values) {
        var wc = this->createWhereClause(WhereClause::EQ, id);
        return this->incrementByWhereClause(wc, values);
    }

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

    public function deleteById(id) {
        var wc = this->createWhereClause(WhereClause::EQ, id);
        return this->deleteByWhereClause(wc);
    }

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
        //var_dump(ret);
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