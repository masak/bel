#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (mod 10 2)
0

> (mod 10 3)
1

> (mod 5 4)
1

> (mod 6 4)
2

> (mod 7 3.5)
0

> (mod 8 3.5)
1

