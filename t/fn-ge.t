#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (>= 1 1 1)
t

> (>= 3 2 0)
t

> (>= 1 2 3)
nil

> (>= 1 2 1)
nil

> (>= 1)
t

> (>=)
t

