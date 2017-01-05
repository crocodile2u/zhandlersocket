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
    // @var Logger
    private logger;
    /**
     * Constructor. Setup connection parameters.
     * Connection is not established here, this is done only when we need to issue a request
     */
    public function __construct(string host = "127.0.0.1", int portRead = 9998, int portWrite = 9999) {
        let this->host = host;
        let this->portRead = portRead;
        let this->portWrite = portWrite;
        let this->logger = new FakeLogger();
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
                let this->readConnection = this->createConnection(this->portRead);
            } else {
                // we have a write connection: no need to establish a new one for reading
                let this->readConnection = this->writeConnection;
            }
        }
        return this->readConnection;
    }

    public function getWriteConnection() -> <Connection> {
        if null === this->writeConnection {
            let this->writeConnection = this->createConnection(this->portWrite);
        }
        return this->writeConnection;
    }
    /**
     * Enables or disables debug logging (disabled by default).
     * When enabled, debug informarion will be collected and you will be able to get it later with getDebugLog()
     */
    public function setLogger(<Logger> logger) {
        let this->logger = logger;
        if this->readConnection {
            this->readConnection->setDebugLog(this->logger);
        }
        if this->writeConnection {
            this->writeConnection->setDebugLog(this->logger);
        }
    }
    /**
     * Get the debug log
     */
    public function getDebugLog() -> <Logger> {
        return this->logger;
    }

    protected function createConnection(int port) -> <Connection> {
        return new Connection(this->host, port, this->getUsePersistentConnection(), this->logger);
    }
}