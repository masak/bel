#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (odd 0)
nil

> (odd \x)
nil

> (odd -1)
t

> (odd \0)
nil

> (odd 1/2)
nil

> (odd 4/2)
nil

> (odd 6/2)
t

> (odd 3)
t

> (odd 4)
nil

