#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (table)
(lit tab)

> (table nil)
(lit tab)

> (table '((a . b)))
(lit tab (a . b))

> (table '((a . b) (c . nil)))
(lit tab (a . b) (c))

> (table '((a . b) (c . d)))
(lit tab (a . b) (c . d))

> (table '((a . b) (a . d)))
(lit tab (a . b) (a . d))

> (table '((a . 1) (b . 2)))
(lit tab (a . 1) (b . 2))

