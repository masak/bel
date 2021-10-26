#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!cons 'a nil)
(a)

> (bcfn!cons 'a)
a

> (bcfn!cons 'a 'b)
(a . b)

> (bcfn!cons)
nil

> (bcfn!cons 'a 'b 'c '(d e f))
(a b c d e f)

