#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!char 'x)
nil

> (bcfn!char nil)
nil

> (bcfn!char '(a))
nil

> (bcfn!char (join))
nil

> (bcfn!char \c)
t

