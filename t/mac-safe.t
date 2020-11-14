#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (safe (car 'a))
nil

> (safe (car '(1 2)))
1

