#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

The `do1` macro returns the value of the _first_ expression
it evaluates.

> (do1 1
       2)
1

It doesn't matter if the variable the value was originally
from subsequently changes.

> (let x 'hi
    (do1 x
         (set x 'hey)))
hi

However, the subsequent expressions are still evaluated, and
so any side effects from them are still visible.

> (let x 'hi
    (do1 x
         (set y 'hey))
    y)
hey

A (rare) edge case which nevertheless works is that of an empty
sequence of `do1` expressions.

> (do1)
nil

