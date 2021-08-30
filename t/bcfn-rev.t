#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!rev nil)
nil

> (bcfn!rev '(a b c))
(c b a)

> (bcfn!rev '(a (x y) c))
(c (x y) a)

