namespace Zhandlersocket;

abstract class Logger {
    static public function create(bool debug) {
        if debug {
            return new DebugLogger();
        } else {
            return new NullLogger();
        }
    }
    public abstract function write(string message) -> void;
    public abstract function timerStart(string label) -> void;
    public abstract function timerEnd(string label) -> void;
    public abstract function export() -> array;
}