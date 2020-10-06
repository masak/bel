#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (inc 0)
1

> (inc 1)
2

> (inc 3)
4

> (inc -1)
0

> (inc -4.5)
-7/2

> (inc .5)
3/2

