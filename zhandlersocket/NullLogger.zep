namespace Zhandlersocket;

class NullLogger extends Logger {
    public function write(string message) -> void {

    }
    public function timerStart(string label) -> void {

    }
    public function timerEnd(string label) -> void {

    }
    public function export() -> array {
        return [];
    }
}