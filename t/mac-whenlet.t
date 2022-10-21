#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (whenlet x nil)
nil

> (whenlet y 'a
    (list y 'b))
(a b)

> (whenlet z 'a
    (list 'b z)
    'c)
c

> (whenlet z nil
    (list 'b z)
    'c)
nil

If the condition is not true, side effects do not run.

> (set x "original")
"original"

> (whenlet w nil
    (set x "changed"))
nil

> x
"original"

> (whenlet (a b . c) '(1 2 3 4 5)
    (list a b c)
    b)
2

> (whenlet (a b . c) nil
    (list a b c)
    c)
nil

