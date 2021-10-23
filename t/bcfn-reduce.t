#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!reduce join '(a b c))
(a b . c)

> (bcfn!reduce (fn (x y) x) '(a b c))
a

> (bcfn!reduce (fn (x y) y) '(a b c))
c

> (bcfn!reduce join '())
nil

