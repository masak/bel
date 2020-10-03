#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (first 1 '(a b c))
(a)

If the number exceeds the length of the list, the full
list is returned.

> (first 4 '(a b c))
(a b c)

> (first 2 nil)
nil

