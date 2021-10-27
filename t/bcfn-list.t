#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!list)
nil

> (bcfn!list 'a)
(a)

> (bcfn!list 'a 'b)
(a b)

