#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (check t idfn)
t

> (check nil idfn)
nil

> (check 2 is.2)
2

> (check 1 is.2)
nil

> (check 2 is.2 0)
2

> (check 1 is.2 0)
0

> (set x 1)
1

> (check (++ x) is.2))
2

> x
2

