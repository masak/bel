#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (common '(a b c) '(d e f))
nil

> (common '(a b c) '(d a f))
(a)

> (common '(a b c) '(d a a))
(a)

> (common '(a a c) '(d a a))
(a a)

> (common '(2 2 5 5) '(2 3 5))
(2 5)

