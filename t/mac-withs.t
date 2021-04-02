#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (withs ()
    (cons 'b 'a))
(b . a)

> (withs (x 'a
          y 'b)
    (cons x y))
(a . b)

> (withs (x 'a y x)
    (cons x y))
(a . a)

The outer binding of a variable that's about to be bound is visible
when evaluating the expression to be bound.

> (let x 'a
    (withs (x x
            y x)
      y))
a

> (withs (x 'a y)
    (cons x y))
(a)

