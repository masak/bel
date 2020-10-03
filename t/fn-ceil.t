#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (ceil 3.5)
4

> (ceil 3)
3

> (ceil -3.5)
-3

> (ceil -3)
-3

