#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (join 'a 'b)
(a . b)

> (join 'a)
(a)

> (join)
(nil)

> (join nil 'b)
(nil . b)

> (id (join 'a 'b) (join 'a 'b))
nil

