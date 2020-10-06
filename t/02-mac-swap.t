#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (let (x y z) '(a b c)
    (swap x y z)
    (list x y z))
(b c a)

> (let x '(a b c d e)
    (swap 2.x 4.x)
    x)
(a d c b e)

