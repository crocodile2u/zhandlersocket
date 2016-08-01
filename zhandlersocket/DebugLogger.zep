namespace Zhandlersocket;

/**
 * A logger that is created when we are in debug mode
 */

class DebugLogger extends Logger {
    // @var string[]
    private messages = [];
    // @var float[]
    private timers = [];
    // @implements Logger
    public function write(string message) -> bool {
        let this->messages[] = message;
        return true;
    }
    // @implements Logger
    public function timerStart(string label) -> bool {
        let this->timers[label] = microtime(true);
        return true;
    }
    // @implements Logger
    public function timerEnd(string label) -> bool {
        if !isset this->timers[label] {
            let this->timers[label] = 0.0;
        }
        var elapsed = this->sub(microtime(true), this->timers[label]);
        var elapsedUs = ceil(elapsed * 1000000);// Micro, Carl! MICRO !!!
        var msg = sprintf("%s: %d us elapsed", label, elapsedUs);
        this->write(msg);
        unset this->timers[label];
        return true;
    }
    // @implements Logger
    public function export() -> array {
        return this->messages;
    }
    /**
     * For whatever reason, I could not just do this simple math: microtime(true) - this->timers[label]
     * It always produces Zephir\CompilerException: Unknown type: sub
     */
    private function sub(float v1, float v2) {
        return v1 - v2;
    }
}