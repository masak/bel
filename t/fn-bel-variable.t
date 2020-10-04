#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel 'vmark)
(nil)

> (bel '((lit clo nil (x) x) 'g))
g

> (bel '((lit clo nil (x) (where x)) 'g))
((x . g) d)

