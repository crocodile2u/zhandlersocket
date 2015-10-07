namespace ZHandlersocket;
/**
 * Debug log for read and write connections
 */
class Log {
    private read = "" {get,set};
    private write = "" {get,set};

    public function toString() -> string {
        return sprintf("READ LOG:\n%s\nWRITE LOG:\n%s\n\n", this->read, this->write);
    }
}