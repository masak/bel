#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set x '(1 2 3 4 5)
(1 2 3 4 5)

> (clean odd x)
(2 4)

> x
(2 4)

