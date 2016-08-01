namespace Zhandlersocket;

abstract class Logger {
    static public function create(bool debug) {
        if debug {
            return new DebugLogger();
        } else {
            return new FakeLogger();
        }
    }
    public abstract function write(string message) -> bool;
    public abstract function timerStart(string label) -> bool;
    public abstract function timerEnd(string label) -> bool;
    public abstract function export() -> array;
}