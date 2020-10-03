#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (foldr cons nil '(a b))
(a b)

> (cons 'a (foldr cons nil '(b)))
(a b)

> (cons 'a (cons 'b (foldr cons nil nil)))
(a b)

> (foldr put nil '(a b c) '(x y z))
((a . x) (b . y) (c . z))

> (foldr err nil)
nil

