namespace Zhandlersocket;

class WhereClause {
    // comparison types
    const EQ = "=";
    const GT = ">";
    const GTE = ">=";
    const LT = "<";
    const LTE = "<=";
    // @var Index
    private index;
    // operation (one of comparison types)
    private op;
    // index column value(s) to filter by
    private keyValues = [];

    private limit = 1;
    private offset = 0;

    // IN clause spec
    private inColumn;
    private inValues = [];

    // additional FILTERs
    private filters = [];

    public function __construct(<Index> index, string op, keyValues) {
        let this->index = index;
        let this->op = op;
        if is_array(keyValues) {
            let this->keyValues = keyValues;
        } else {
            let this->keyValues = [keyValues];
        }
    }

    public function setLimit(int limit, int offset = 0) -> <WhereClause> {
        let this->limit = limit;
        let this->offset = offset;
        return this;
    }

    public function setIn(array values, column = null) -> <WhereClause> {
        let this->inColumn = this->index->getColumnIndex(column);
        let this->inValues = values;
        return this->setLimit(count(values));
    }

    public function addFilter(string op, string column, value, string type = WhereClauseFilter::TYPE_FILTER) -> <WhereClause> {
        var columnIndex = this->index->getFcolumnIndex(column);
        let this->filters[] = new WhereClauseFilter(op, columnIndex, value, type);
        return this;
    }

    public function find() {
        return this->index->findByWhereClause(this);
    }

    public function toArray() -> array {
        var tokens = [
            this->op,
            count(this->keyValues)
        ];
        let tokens = array_merge(tokens, this->keyValues, [this->limit, this->offset]);
        if null !== this->inColumn {
            let tokens = array_merge(tokens, ["@", this->inColumn, count(this->inValues)], this->inValues);
        }

        var filter;
        for filter in this->filters {
            let tokens = array_merge(tokens, filter->toArray());
        }

        return tokens;
    }
}