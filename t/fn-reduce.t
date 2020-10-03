#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (reduce join '(a b c))
(a b . c)

> (reduce (fn (x y) x) '(a b c))
a

> (reduce (fn (x y) y) '(a b c))
c

> (reduce join '())
nil

