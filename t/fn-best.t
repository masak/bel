#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (best < '(5 1 3 2 4))
1

> (best > '(5 1 3 2 4))
5

> (best (of > len) '((a b) (c) (d e) (f)))
(a b)

> (best (of < len) '((a b) (c) (d e) (f)))
(c)

