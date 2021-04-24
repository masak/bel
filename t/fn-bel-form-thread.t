#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(thread (car '(x . y))))
x

> (bel '(thread))
!ERROR: bad-form

> (bel '(thread a b))
!ERROR: bad-form

