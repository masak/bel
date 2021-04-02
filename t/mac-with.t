#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (with (x 'a y 'b) (cons x y))
(a . b)

> (let x 'a (with (x 'b y x) y))
a

> (with (x 'a y) y)
nil

