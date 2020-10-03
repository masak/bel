#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (dec 0)
-1

> (dec 1)
0

> (dec 3)
2

> (dec -1)
-2

> (dec -4.5)
-11/2

> (dec .5)
-1/2

