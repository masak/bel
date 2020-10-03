#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> templates
(lit tab)

> (tem point x 0 y 0)
((x lit clo nil nil 0) (y lit clo nil nil 0))

> (make point)
(lit tab (x . 0) (y . 0))

> (set p (make point x 1 y 5))
(lit tab (x . 1) (y . 5))

> p!x
1

> (++ p!x)
2

> p!x
2

> (swap p!x p!y)
!IGNORE: whatever it is `swap` returns

> p
(lit tab (x . 5) (y . 2))

> (set above (of > !y))
!IGNORE: result of assignment

This example is from bellanguage.txt.

> (with (p (make point y 1)
         q (make point x 1 y 5))
    (above q p (make point)))
t

