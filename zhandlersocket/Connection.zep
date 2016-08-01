namespace Zhandlersocket;

/**
 * Hanslersocket connection encapsulation
 */

class Connection {

    const DEFAULT_CONNECTION_TIMEOUT = 5;

    const DEFAULT_IO_TIMEOUT = 1.0;
    // @var string
    private host;
    // @var int
    private port;
    // @var int
    private connectionTimeout = self::DEFAULT_CONNECTION_TIMEOUT;
    // Input/Output timeout
    // @var int
    private ioTimeout = self::DEFAULT_IO_TIMEOUT { set };
    // @var bool
    private persistent;
    // @var bool
    private connected = false;
    // @var resource
    private connResource;
    // @var Log
    private debugLog;
    /**
     * Constructor. Setup connection params, initialize Logger
     */
    protected function __construct(string host = "127.0.0.1", int port, bool persistent = false, <Logger> logger = null) {
        let this->host = host;
        let this->port = port;
        let this->persistent = persistent;
        let this->debugLog = logger ?: new FakeLogger();
    }
    /**
     * Send a command and receive response.
     * Response is parsed, decoded and returned as array of strings
     */
    public function send(string cmd) {
        var label = "send";
        this->debugLog->timerStart(label);
        this->debugLog->write(sprintf("[%s:%d] > %s", this->host, this->port, rtrim(cmd)));

        var e;
        try {
            var connectLabel = "connect";
            this->debugLog->timerStart(connectLabel);

            this->connect();// ensure connection

            this->debugLog->timerEnd(connectLabel);

            var len = mb_strlen(cmd, "8bit");// strlen in bytes

            var writeLabel = "write";
            this->debugLog->timerStart(writeLabel);

            var bytesWritten = fwrite(this->connResource, cmd, len);

            this->debugLog->timerEnd(writeLabel);

            if (bytesWritten === len) {// match!
                var readLabel = "read";
                this->debugLog->timerStart(readLabel);

                var responseLine = this->receiveLine();
                this->debugLog->write(sprintf("[%s:%d] < %s", this->host, this->port, join("\t", responseLine)));

                this->debugLog->timerEnd(readLabel);
                this->debugLog->timerEnd(label);

                return responseLine;
            } else {
                throw new CommunicationException("Send: Socket timed out or got an error");
            }
        } catch \Exception, e {
            this->disconnect();
            throw e; //rethrow
        }
    }

    private function receiveLine() -> array {
        var line = fgets(this->connResource);
        if false === line {
            throw new CommunicationException("Receive: Socket timed out or got an error");
        }
        if ("\n" !== mb_substr(line, -1)) {
            throw new CommunicationException("Received malformed response: " . rawurlencode(line));
        }

        return Command::decode(mb_substr(line, 0, -1));
    }

    public function connect() -> bool {

        if this->connected {
            return true;
        }

        var addr;
        let addr = sprintf("%s:%d", this->host, this->port);

        int flags;
        let flags = STREAM_CLIENT_CONNECT;
        if this->persistent {
            let flags = flags | STREAM_CLIENT_PERSISTENT;
        }

        var conn;
        var errCode = 0, errMessage = "";
        let conn = stream_socket_client("tcp://" . addr . "/", errCode, errMessage, this->connectionTimeout, flags);
        if !conn {
            throw new ConnectionException(sprintf("Zhandlersocket unable to connect (error %d: %s)", errCode, errMessage));
        }

        // set stream timeout
        var timeoutSeconds, timeoutUSeconds;
        let timeoutSeconds  = floor(this->ioTimeout);
        let timeoutUSeconds  = floor((this->ioTimeout - timeoutSeconds) * 1000000);
        stream_set_timeout(conn, timeoutSeconds, timeoutUSeconds);

        let this->connResource = conn;
        let this->connected = true;

        return true;
    }

    public function disconnect() -> bool {
        if !this->connected {
            return true;
        }

        let this->connected = false;

        if !is_resource(this->connResource) {
            return true;
        }

        stream_socket_shutdown(this->connResource, STREAM_SHUT_RDWR);
        // the line below fails constantly so I commented it out for now
        //fclose(this->connResource);
        let this->connResource = false;

        return true;
    }

    public function setDebugLog(<Logger> logger) -> void {
        let this->debugLog = logger;
    }

    public function getDebugLog() -> <Logger> {
        return this->debugLog;
    }

    public function __destruct() {
        this->disconnect();
    }
}