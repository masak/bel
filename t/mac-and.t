#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (and)
t

> (and nil)
nil

> (and t)
t

> (and 'a)
a

> (and 'b nil 'c)
nil

Later side effects don't run if the conjunction has already
been falsified.

> (set x "original")
"original"

> (and nil (set x "changed"))
nil

> x
"original"

