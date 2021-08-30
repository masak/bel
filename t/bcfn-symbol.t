#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!symbol 'x)
t

> (bcfn!symbol nil)
t

> (bcfn!symbol '(a))
nil

> (bcfn!symbol (join))
nil

> (bcfn!symbol \c)
nil

