#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (symbol 'x)
t

> (symbol nil)
t

> (symbol '(a))
nil

> (symbol (join))
nil

> (symbol \c)
nil

