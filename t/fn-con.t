#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> ((con 'a) 'b)
a

> ((con nil) 'c)
nil

> ((con '(x y)) nil)
(x y)

> (map (con t) '(a b c))
(t t t)

