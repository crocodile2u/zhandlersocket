namespace Zhandlersocket;

class Connection {
    const DEFAULT_CONNECTION_TIMEOUT = 5;

    const DEFAULT_IO_TIMEOUT = 1.0;

    private host;

    private port;

    private connectionTimeout = self::DEFAULT_CONNECTION_TIMEOUT;

    private ioTimeout = self::DEFAULT_IO_TIMEOUT;

    private persistent;

    private connected = false;

    private connResource;

    private debugLog;

    protected function __construct(string host = "127.0.0.1", int port, bool persistent = false) {
        let this->host = host;
        let this->port = port;
        let this->persistent = persistent;
        let this->debugLog = new NullLogger();
    }

    public function send(string cmd) {
        var label = "send";
        this->debugLog->timerStart(label);
        this->debugLog->write(sprintf("> %s", rtrim(cmd)));
        //echo "> " . cmd;
        var e;
        try {
            var connectLabel = "connect";
            this->debugLog->timerStart(connectLabel);

            this->connect();

            this->debugLog->timerEnd(connectLabel);

            var len = mb_strlen(cmd, "8bit");

            var writeLabel = "write";
            this->debugLog->timerStart(writeLabel);

            var bytesWritten = fwrite(this->connResource, cmd, len);

            this->debugLog->timerEnd(writeLabel);

            if (bytesWritten === len) {
                var readLabel = "read";
                this->debugLog->timerStart(readLabel);

                var responseLine = this->receiveLine();
                this->debugLog->write(sprintf("< %s", join("\t", responseLine)));

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

    public function receiveLine() -> array|bool {
        var line = fgets(this->connResource);
        //echo "< " . line . "\n";
        if false === line {
            throw new CommunicationException("Receive: Socket timed out or got an error");
        }
        if ("\n" !== mb_substr(line, -1)) {
            throw new CommunicationException("Received malformed response: " . rawurlencode(line));
        }

        return explode("\t", mb_substr(line, 0, -1));
    }

    public function connect() {

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
        let conn = stream_socket_client("tcp://" . addr . "/", null, null, this->connectionTimeout, flags);
        if !conn {
            throw new ConnectionException("Zhandlersocket unable to connect");
        }

        var timeoutSeconds, timeoutUSeconds;
        let timeoutSeconds  = floor(this->ioTimeout);
        let timeoutUSeconds  = floor((this->ioTimeout - timeoutSeconds) * 1000000);
        stream_set_timeout(conn, timeoutSeconds, timeoutUSeconds);

        let this->connResource = conn;
        let this->connected = true;

        return true;
    }

    public function disconnect() {
        if !this->connected {
            return true;
        }

        let this->connected = false;

        if !is_resource(this->connResource) {
            return true;
        }

        //stream_socket_shutdown(this->connResource, STREAM_SHUT_RDWR);
        //fclose(this->connResource);
        let this->connResource = false;

        return true;
    }

    public function __destruct() {
        this->disconnect();
    }

    public function setDebugLog(<Logger> logger) -> void {
        let this->debugLog = logger;
    }

    public function getDebugLog() -> <Logger> {
        return this->debugLog;
    }
}