#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (^w 5 1)
5

> (^w 5 0)
1

> (^w 3 2)
9

> (^w 2 3)
8

> (^w 1.5 1)
3/2

> (^w 1.5 0)
1

> (^w 1.5 2)
9/4

> (^w 5 -1)
!ERROR: mistype

