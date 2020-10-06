#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (pint 0)
nil

> (pint \x)
nil

> (pint -1)
nil

> (pint 1)
t

> (pint 1/2)
nil

> (pint 4/2)
t

> (pint -4/2)
nil

