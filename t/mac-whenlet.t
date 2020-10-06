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


