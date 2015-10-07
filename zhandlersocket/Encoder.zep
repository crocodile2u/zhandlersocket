namespace Zhandlersocket;

class Encoder {

    const SHIFT = 0x40;
    const PREFIX = 0x01;
    private static map = null;
    private static rMap = null;

    /**
     * Encode string for HS protocol
     *
     * @param string data
     */
    public static function encode(string data) {
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

    public static function decode(data) {
        if 0x00 === data {
            return null;
        }

        return strtr(data, self::rMap());
    }

    private static function map() {
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

    private static function rMap() {
        if null === self::rMap {
            let self::rMap = array_flip(self::map());
        }

        return self::rMap;
    }
}