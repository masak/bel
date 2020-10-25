#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (readall '(""))
nil

> (readall '("  1 2 3  "))
(1 2 3)

> (readall '("(foo bar) (baz)"))
((foo bar) (baz))

> (readall '("10 12 3"))
(10 12 3)

> (readall '("10 12 3") 10)
(10 12 3)

> (readall '("10 12 3") 4)
(4 6 3)

