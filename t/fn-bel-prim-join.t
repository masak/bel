#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(join 'a 'b))
(a . b)

> (bel '(join 'a))
(a)

> (bel '(join))
(nil)

> (bel '(join nil 'b))
(nil . b)

> (bel '(id (join 'a 'b) (join 'a 'b)))
nil

