namespace Zhandlersocket;

class DebugLogger extends Logger {
    private messages = [];
    private timers = [];
    public function write(string message) -> void {
        let this->messages[] = message;
    }
    public function timerStart(string label) -> void {
        let this->timers[label] = microtime(true);
    }
    public function timerEnd(string label) -> void {
        if !isset this->timers[label] {
            let this->timers[label] = 0.0;
        }
        var elapsed = this->sub(microtime(true), this->timers[label]);
        var elapsedUs = ceil(elapsed * 1000000);
        var msg = [label, ": ", elapsedUs, " us elapsed"];
        this->write(join("", msg));
        unset this->timers[label];
    }
    public function export() -> array {
        return this->messages;
    }
    private function sub(float v1, float v2) {
        return v1 - v2;
    }
}