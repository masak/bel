#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (saferead '("12") nil 10)
12

> (saferead '("12") nil 3)
5

> (saferead '("(foo bar baz)"))
(foo bar baz)

> (saferead '("\\"))
nil

> (saferead '("\\") 'alt)
alt

