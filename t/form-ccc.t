#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (list 'a (ccc (fn (c) (set cont c) 'b)))
(a b)

> (cont 'z)
(a z)

> (cont 'w)
(a w)

