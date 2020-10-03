#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (cddr nil)
nil

> (cddr '(a))
nil

> (cddr '(a b))
nil

> (cddr '(a b c))
(c)

