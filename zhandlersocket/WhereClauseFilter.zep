namespace Zhandlersocket;

class WhereClauseFilter {

    const TYPE_FILTER = "F";
    const TYPE_WHILE = "W";

    private type;
    private op;
    private column;
    private value;

    public function __construct(string op, int column, value, string type = self::TYPE_FILTER) {
        let this->type = type;
        let this->op = op;
        let this->column = column;
        let this->value = value;
    }

    public function toArray() {
        return [this->type, this->op, this->column, this->value];
    }
}