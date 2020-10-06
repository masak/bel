#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (sort < '(5 1 3 2 4))
(1 2 3 4 5)

> (sort (of > len)
        '((a b) (c) (d e) (f)))
((a b) (d e) (c) (f))

