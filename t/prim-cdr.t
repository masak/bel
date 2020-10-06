#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (cdr '(a . b))
b

> (cdr '(a b))
(b)

> (cdr nil)
nil

> (cdr)
nil

> (cdr 'atom)
!ERROR: cdr-on-atom

