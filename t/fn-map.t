#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (map car '((a b) (c d) (e f)))
(a c e)

> (map cons '(a b c) '(1 2 3))
((a . 1) (b . 2) (c . 3))

If lists of differing lengths are passed to `map`, the result will have
the length of the shortest list.

> (map cons '(a b c) '(1 2))
((a . 1) (b . 2))

> (map join)
nil

> (map list '(1 2) '(a b . c))
((1 a) (2 b))

