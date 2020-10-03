#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (foldl cons nil '(a b))
(b a)

> (foldl cons (cons 'a nil) '(b))
(b a)

> (foldl cons (cons 'b (cons 'a nil)) nil)
(b a)

> (foldl put nil '(a b c) '(x y z))
((c . z) (b . y) (a . x))

> (foldl err nil)
nil

