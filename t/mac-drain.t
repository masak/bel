#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set x '(a b c d e))
(a b c d e)

> (drain (pop x))
(a b c d e)

> x
nil

> (set x '(a b c d e))
(a b c d e)

> (drain (pop x) (is 'd))
(a b c)

> x
(e)

