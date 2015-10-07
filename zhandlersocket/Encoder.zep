namespace Zhandlersocket;

/**
 * Because HS uses a simple text protocol, certain characters need to be encoded when sent to server and decoded back where sent back
 */

class Encoder {

    const SHIFT = 0x40;
    const PREFIX = 0x01;
    // @var string[]
    private static map = null;
    // @var string[]
    private static rMap = null;

    /**
     * Encode string for HS protocol
     *
     * @param string data
     */
    public static function encode(string data) -> string|int {
        /*
         * - Characters in the range [0x10 - 0xff] are not encoded.
         * - A character in the range [0x00 - 0x0f] is prefixed by 0x01 and
         *   shifted by 0x40. For example, 0x03 is encoded as 0x01 0x43.
         * - NULL is expressed as a single NUL(0x00).
         */

        if (data === null) {
            return 0x00;
        }

        return strtr(data, self::map());
    }

    public static function decode(data) -> string|null {
        if 0x00 === data {
            return null;
        }

        return strtr(data, self::rMap());
    }

    private static function map() -> array {
        if null === self::map {
            let self::map = [];
            var pref = chr(self::PREFIX);
            int i;
            for i in range(0x01, 0x0f) {
                let self::map[chr(i)] = pref . chr(i + self::SHIFT);
            }
        }

        return self::map;
    }

    private static function rMap() -> array {
        if null === self::rMap {
            let self::rMap = array_flip(self::map());
        }

        return self::rMap;
    }
}