#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (atom [id _ t])
nil

> ([id _ 'd] 'd)
t

> (map [car _] '((a b) (c d) (e f)))
(a c e)

> ([] t)
nil

