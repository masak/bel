#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (onerr 'oops (car 'a))
oops

> (onerr 'no-oops (car '(1 2)))
1

