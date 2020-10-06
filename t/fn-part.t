#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> ((part cons 'a) 'b)
(a . b)

> ((part list 1 2 3) 4 5)
(1 2 3 4 5)

> ((part no) t)
nil

> ((part no) nil)
t

