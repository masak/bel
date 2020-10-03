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

