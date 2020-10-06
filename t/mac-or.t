#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (or)
nil

> (or nil)
nil

> (or nil t)
t

> (or nil 'a)
a

> (or nil 'b 'c)
b

Later side effects don't run if the disjunction has already been
satisfied by an earlier expression.

> (set x "original")
"original"

> (or t (set x "changed"))
t

> x
"original"

