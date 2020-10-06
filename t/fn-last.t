#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (last nil)
nil

> (last '(a))
a

> (last '(a b))
b

> (last '(a b c))
c

> (last '(a b nil))
nil

