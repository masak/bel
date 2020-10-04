#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(car '(a . b)))
a

> (bel '(car '(a b)))
a

> (bel '(car nil))
nil

> (bel '(car))
nil

> (bel '(car 'atom))
!ERROR: car-on-atom

