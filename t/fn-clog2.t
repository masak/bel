#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (clog2 0)
1

> (clog2 1)
1

> (clog2 2)
1

> (clog2 3)
2

> (clog2 4)
2

> (clog2 7)
3

> (clog2 8)
3

> (clog2 11)
4

