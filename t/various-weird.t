#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set s (open "README.md" 'in))
<stream>

> (mac mmm () s)
!IGNORE: result of macro evaluation

> (mmm)
<stream>

> (set f '(lit . fn))
!IGNORE: result of 'set'

> (f)
!ERROR: bad-lit

> (let f1 (fn t)
    (f1))
!ERROR: bad-clo

> (let f2 (fn o)
    (f2))
!ERROR: bad-clo

> (let f3 (fn apply)
    (f3))
!ERROR: bad-clo

> (let f4 (fn (t x int y))
    (f4))
!ERROR: bad-clo

> (let f5 (fn (o y 0))
    (f5))
!ERROR: bad-clo

> (let f6 (fn (o y))
    (f6))
!ERROR: bad-clo

> (let f7 (fn (o y (+ 2 2)))
    (f7))
!ERROR: bad-clo

> (let f8 (fn (o y 0 x))
    (f8))
!ERROR: bad-clo

> (let f9 (fn (a (o b 0 1) c))
    (f9))
!ERROR: bad-clo

> ((lit cont ((x)) nil))
!ERROR: bad-cont

> ((lit cont nil (1 . 2)))
!ERROR: bad-cont

Here I would add a test for literal-parm, but I found no way to trigger it;
everything I tried hit bad-clo instead.

> (ccc (fn (c) (c)))
!ERROR: wrong-no-args

> (ccc (fn (c) (c 1 2)))
!ERROR: wrong-no-args

> (ccc (fn (c) (c 5)))
5

