#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (floor 3.5)
3

> (floor 3)
3

> (floor -3.5)
-4

> (floor -3)
-3

