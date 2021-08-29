#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!cddr nil)
nil

> (bcfn!cddr '(a))
nil

> (bcfn!cddr '(a b))
nil

> (bcfn!cddr '(a b c))
(c)

