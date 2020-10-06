#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> ((flip -) 1 10)
9

> ((flip list) 5 4 3 2 1)
(1 2 3 4 5)

> ((flip all) '(nil nil nil) no)
t

