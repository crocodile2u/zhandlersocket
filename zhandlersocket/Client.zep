namespace Zhandlersocket;
/**
 * Client class. Holds read/write connections (caches the connections internally);
 * responsible for creating Index instances;
 *
 * @package Zhandlersocket
 * @author Victor Bolshov <crocodile2u@gmail.com>
 */
class Client {
    // @var string
    private host;
    // @var int
    private portRead;
    // @var int
    private portWrite;
    // @var Index[]
    private indexes = [];
    // @var Connection
    private readConnection;
    // @var Connection
    private writeConnection;
    // @var bool
    private usePersistentConnection = true {
        get, set
    };
    // @var bool
    private enableDebug = false;
    /**
     * Constructor. Setup connection parameters.
     * Connection is not established here, this is done only when we need to issue a request
     */
    public function __construct(string host = "127.0.0.1", int portRead = 9998, int portWrite = 9999) {
        let this->host = host;
        let this->portRead = portRead;
        let this->portWrite = portWrite;
    }
    /**
     * get create indexes count
     */
    public function getIndexCount() -> int {
        return count(this->indexes);
    }
    /**
     * Get a index from a pool or create a new one and put it into the pool
     */
    public function getIndex(string dbname, string table, string idx, array cols, fcols = null) -> <Index> {
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

    public function getReadConnection() -> <Connection> {
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

    public function getWriteConnection() -> <Connection> {
        if null === this->writeConnection {
            let this->writeConnection = new Connection(this->host, this->portWrite, this->getUsePersistentConnection());
            this->writeConnection->setDebugLog(Logger::create(this->enableDebug));
        }
        return this->writeConnection;
    }
    /**
     * Enables or disables debug logging (disabled by default).
     * When enabled, debug informarion will be collected and you will be able to get it later with getDebugLog()
     */
    public function setEnableDebug(bool flag) {
        let this->enableDebug = flag;
        if this->readConnection {
            this->readConnection->setDebugLog(Logger::create(flag));
        }
        if this->writeConnection {
            this->writeConnection->setDebugLog(Logger::create(flag));
        }
    }
    /**
     * Get the debug log
     */
    public function getDebugLog() -> <Log> {
        var ret;
        let ret = new Log();
        if this->readConnection {
            ret->setRead(join("\n", this->readConnection->getDebugLog()->export()));
        }
        if this->writeConnection {
            ret->setWrite(join("\n", this->writeConnection->getDebugLog()->export()));
        }
        return ret;
    }
}