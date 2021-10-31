#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (list)
nil

> (list 'a)
(a)

> (list 'a 'b)
(a b)

> (let p '(a b c)
    (id (apply list p) p))
nil

