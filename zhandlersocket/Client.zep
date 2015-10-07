namespace Zhandlersocket;

class Client {

    private host;

    private portRead;

    private portWrite;

    private indexes = [];

    private readConnection;
    private writeConnection;

    private usePersistentConnection = true {
        get, set
    };

    private enableDebug = false;

    public function __construct(host = "127.0.0.1", portRead = 9998, portWrite = 9999) {
        let this->host = host;
        let this->portRead = portRead;
        let this->portWrite = portWrite;
    }

    public function getIndexCount() -> int {
        return count(this->indexes);
    }

    public function getIndex(string dbname, string table, string idx, array cols, fcols = null) {
        var fcolsStr;
        if (null === fcols) {
            let fcolsStr = ".";
        } else {
            let fcolsStr = join(",", fcols);
        }
        var args = [dbname, table, idx, cols->join(","), fcolsStr];
        var hash = join("/", args);
        if !isset this->indexes[hash] {
            let this->indexes[hash] = new Index(this, dbname, table, idx, cols, fcols);
        }
        return this->indexes[hash];
    }

    public function getReadConnection() {
        if null === this->readConnection {
            if null === this->writeConnection {
                let this->readConnection = new Connection(this->host, this->portRead, this->getUsePersistentConnection());
                this->readConnection->setDebugLog(Logger::create(this->enableDebug));
            } else {
                // we have a write connection: no need to establish a new one for reading
                let this->readConnection = this->writeConnection;
            }
        }
        return this->readConnection;
    }

    public function getWriteConnection() {
        if null === this->writeConnection {
            let this->writeConnection = new Connection(this->host, this->portWrite, this->getUsePersistentConnection());
            this->writeConnection->setDebugLog(Logger::create(this->enableDebug));
        }
        return this->writeConnection;
    }

    public function setEnableDebug(bool flag) {
        let this->enableDebug = flag;
        if this->readConnection {
            this->readConnection->setDebugLog(Logger::create(flag));
        }
        if this->writeConnection {
            this->writeConnection->setDebugLog(Logger::create(flag));
        }
    }

    public function getDebugLog() -> array {
        var ret = [];
        if this->readConnection {
            let ret["R"] = this->readConnection->getDebugLog()->export();
        }
        if this->writeConnection {
            let ret["W"] = this->writeConnection->getDebugLog()->export();
        }
        return ret;
    }
}