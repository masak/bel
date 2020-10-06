#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (do
    (def foo (x) x)
    (foo 'a))
a

> (do
    (def bar (x) (cons x x))
    (bar 'a))
(a . a)

