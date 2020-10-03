#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set L nil)
nil

> (loop x 1 (+ x 1) (< x 5)
    (push x L))
nil

> L
(4 3 2 1)

> (set L nil)
nil

> (loop x 1 (+ x 1) (< x 1)
    (push x L))
nil

> L
nil

