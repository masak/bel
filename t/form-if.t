#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (if)
nil

> (if 'a)
a

> (if 'a 'b)
b

> (if 'a 'b 'c)
b

> (if nil 'b 'c)
c

