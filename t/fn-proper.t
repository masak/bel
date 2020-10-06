#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (proper nil)
t

> (proper '(a . b))
nil

> (proper '(a b))
t

