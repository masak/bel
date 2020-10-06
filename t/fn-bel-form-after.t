#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(after 1 2))
1

> (bel '(after 3 (car 'atom)))
!ERROR: car-on-atom

