#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (round -2.5)
-2

> (round -1.5)
-2

> (round -1.4)
-1

> (round 1.4)
1

> (round 1.5)
2

> (round 2.5)
2

