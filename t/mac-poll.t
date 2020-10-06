#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (let x '(a b c d e)
    (poll (pop x) (is 'c))
    x)
(d e)

> (let x '(c)
    (poll (pop x) (is 'c))
    x)
nil

