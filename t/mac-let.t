#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (let x 'a
    (cons x 'b))
(a . b)

`let` declarations can shadow one another, creating a lexically
nested structure of definitions.

> (let x 'a
    (cons (let x 'b
            x)
    x))
(b . a)

> (let x 'a
    (let y 'b
      (list x y)))
(a b)

