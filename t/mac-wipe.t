#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (let x 'hi
    (wipe x)
    x)
nil

> (let x '(a b c d e)
    (wipe 2.x 4.x)
    x)
(a nil c nil e)

