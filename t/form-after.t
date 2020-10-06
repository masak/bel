#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (after 1 2)
1

> (after 3 (car 'atom))
!ERROR: car-on-atom

> (do (after (set x 1)
             (set x 2))
      x)
2

