#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (pair 'x)
nil

> (pair nil)
nil

> (pair '(a))
t

> (pair (join))
t

> (pair \c)
nil

