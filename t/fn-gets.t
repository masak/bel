#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (let L '((a . 1) (b . 2) (c . 3))
    (gets 2 L))
(b . 2)

> (let L '((a . 1) (b . 2) (c . 3))
    (gets 4 L))
nil

> (let L nil
    (gets 5 L))
nil

> (let L '((1 . (a))
           (2 . (b))
           (3 . (c)))
    (gets '(b) L))
(2 b)

> (let L '((1 . (a))
           (2 . (b))
           (3 . (c)))
    (gets '(b) L id))
nil

> (withs (q '(b)
          L `((1 . (a))
              (two . ,q)
              (3 . (c))))
    (gets q L id))
(two b)

