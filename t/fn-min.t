#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (min 5 1 3 2 4)
1

> (min 3 1 -2 4 0)
-2

