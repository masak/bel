#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (iflet x)
nil

> (iflet y 'a
    (list y 'b))
(a b)

> (iflet z 'a
    (list 'b z)
    'c)
(b a)

> (iflet w nil
    (list 'd w)
    'e)
e

> (iflet (a b . c) '(1 2 3 4 5)
    (list a b c)
    'flurken)
(1 2 (3 4 5))

> (iflet (a b . c) nil
    (list a b c)
    'gherkin)
gherkin

