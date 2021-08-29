#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!string nil)
t

> (bcfn!string "")
t

> (bcfn!string "hello bel")
t

> (bcfn!string 'c)
nil

> (bcfn!string \a)
nil

