#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> ((is car) car)
t

> ((is car) cdr)
nil

> ((is 'x) 'x)
t

> ((is 'x) 'y)
nil

> ((is 'x) \x)
nil

> ((is (join)) (join))
t

