#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (char 'x)
nil

> (char nil)
nil

> (char '(a))
nil

> (char (join))
nil

> (char \c)
t

