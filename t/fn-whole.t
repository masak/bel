#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (whole 0)
t

> (whole \x)
nil

> (whole -1)
nil

> (whole 1)
t

> (whole 1/2)
nil

> (whole 4/2)
t

> (whole -4/2)
nil

