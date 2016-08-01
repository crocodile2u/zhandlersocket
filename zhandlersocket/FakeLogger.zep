namespace Zhandlersocket;

class FakeLogger extends Logger {
    public function write(string message) -> bool {
        return true;
    }
    public function timerStart(string label) -> bool {
        return true;
    }
    public function timerEnd(string label) -> bool {
        return true;
    }
    public function export() -> array {
        return [];
    }
}