<?php

//$s = chr(0x03) . chr(0x04);
//$x01 = chr(0x01);

//var_dump(strtr($s, [
//        chr(0x03) => $x01 . chr(0x03 + 0x40),
//        chr(0x04) => $x01 . chr(0x04 + 0x40),
//    ]
//));
//die();
//stream_socket_client();
dl("zhandlersocket.so");
//array_search()
//$orig = "xxx\tyyy";
//$enc = \Zhandlersocket\Encoder::encode($orig);
//var_dump($enc);
//$dec = \Zhandlersocket\Encoder::decode($enc);
//var_dump($dec);
//var_dump($dec === $orig);
//var_dump($enc = \Zhandlersocket\Encoder::encode(null));
//var_dump(\Zhandlersocket\Encoder::decode($enc));

$hs = new \Zhandlersocket\Client();