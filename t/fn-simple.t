#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (simple 'x)
t

> (simple \c)
t

> (simple nil)
t

> (simple '(a b))
nil

> (simple 3)
t

> (simple "ab")
nil

