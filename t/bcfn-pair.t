#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!pair 'x)
nil

> (bcfn!pair nil)
nil

> (bcfn!pair '(a))
t

> (bcfn!pair (join))
t

> (bcfn!pair \c)
nil

