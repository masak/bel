#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!proper nil)
t

> (bcfn!proper '(a . b))
nil

> (bcfn!proper '(a b))
t

