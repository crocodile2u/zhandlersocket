<?php

class EncoderTest extends \PHPUnit_Framework_TestCase {
    function testEncodeNull()
    {
        $this->assertEquals(0x00, \Zhandlersocket\Encoder::encode(null));
    }
    function testDecodeNull()
    {
        $this->assertEquals(null, \Zhandlersocket\Encoder::decode(chr(0x00)));
    }
}