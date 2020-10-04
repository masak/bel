#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(cdr '(a . b)))
b

> (bel '(cdr '(a b)))
(b)

> (bel '(cdr nil))
nil

> (bel '(cdr))
nil

> (bel '(cdr 'atom))
!ERROR: cdr-on-atom

