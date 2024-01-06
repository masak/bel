#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (2:or nil '(a b c))
b

> ((compose 2 or) nil '(a b c))
b

> (apply or nil '(a b c) nil)
(a b c)

