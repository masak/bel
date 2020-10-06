#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (insert < 3 nil)
(3)

> (insert < 3 '(1 2 4 5))
(1 2 3 4 5)

