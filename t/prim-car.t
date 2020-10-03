#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (car '(a . b))
a

> (car '(a b))
a

> (car nil)
nil

> (car)
nil

> (car 'atom)
!ERROR: car-on-atom

