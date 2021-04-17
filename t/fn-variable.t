#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (variable 'foo)
t

> (variable nil)
nil

> (variable t)
nil

> (variable (uvar))
t

> (variable \c)
nil

