#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!snoc '(a b c) 'd 'e)
(a b c d e)

> (bcfn!snoc '())
nil

> (bcfn!snoc)
nil

