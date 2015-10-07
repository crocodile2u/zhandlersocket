namespace Zhandlersocket;

class Command {

    const DELIMITER = "\t";

    static public function open(<Index> index) {
        var tokens = [
            "P",
            index->getNum(),
            index->getDbname(),
            index->getTable(),
            index->getIdx(),
            index->getColsAsString()
        ];
        if index->hasFcols() {
            let tokens[] = index->getFcolsAsString();
        }
        return self::compose(tokens);
    }

    static public function insert(<Index> index, values) {
        var tokens = [index->getNum(), "+", count(values)];
        var colValues = index->mapValues(values);
        let tokens = array_merge(tokens, colValues);
        return self::compose(tokens);
    }

    static public function update(<Index> index, <WhereClause> wc, values) {
        var tokens = array_merge([index->getNum()], wc->toArray(), ["U"], index->mapValues(values));
        return self::compose(tokens);
    }

    static public function increment(<Index> index, <WhereClause> wc, values) {
        var tokens = array_merge([index->getNum()], wc->toArray(), ["+"], index->mapValues(values));
        return self::compose(tokens);
    }

    static public function delete(<Index> index, <WhereClause> wc) {
        var tokens = array_merge([index->getNum()], wc->toArray(), ["D"]);
        return self::compose(tokens);
    }

    static public function encode(array tokens) -> string {
        var encodedTokens = [];
        var tok;
        for tok in tokens {
            let encodedTokens[] = Encoder::encode(tok);
        }
        return join(self::DELIMITER, encodedTokens);
    }

    static public function compose(array tokens) -> string {
        var ret = self::encode(tokens);
        //echo "compose: " . ret . "\n";
        return ret . "\n";
    }
}