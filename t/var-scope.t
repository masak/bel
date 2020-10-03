#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> scope
nil

> ((lit clo nil (x) scope) 'a)
((x . a))

