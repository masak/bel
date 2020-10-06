#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set q '((a b c d)))
((a b c d))

> (deq q)
a

> (deq q)
b

`deq` also affects the nested list, removing elements.

> q
((c d))

> (deq q)
c

> (deq q)
d

> (deq q)
nil

