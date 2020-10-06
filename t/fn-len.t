#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (len nil)
0

> (len '(t))
1

> (len '(t t))
2

> (len '(t t t))
3

> (len '(t t t t))
4

