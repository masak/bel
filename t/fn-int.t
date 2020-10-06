#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (int 0)
t

> (int \x)
nil

> (int -1)
t

> (int \0)
nil

> (int 1/2)
nil

> (int 4/2)
t

