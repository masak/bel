#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!cadr nil)
nil

> (bcfn!cadr '(a))
nil

> (bcfn!cadr '(a b))
b

> (bcfn!cadr '(a b c))
b

