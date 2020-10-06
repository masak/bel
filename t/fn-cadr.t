#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (cadr nil)
nil

> (cadr '(a))
nil

> (cadr '(a b))
b

> (cadr '(a b c))
b

