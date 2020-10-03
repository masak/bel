#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set L '()
       x '(a b c d e))
(a b c d e)

> (til y (pop x) (= y 'c)
    (push y L))
nil

> L
(b a)

> x
(d e)

> (set L '()
       x '(c))
(c)

> (til y (pop x) (= y 'c)
    (push y L))
nil

> x
nil

