#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> ((trap cons 'a) 'b)
(b . a)

> ((trap list 1 2 3) 4 5)
(4 5 1 2 3)

> ((trap no) t)
nil

> ((trap no) nil)
t

