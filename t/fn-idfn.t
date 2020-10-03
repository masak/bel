#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (idfn nil)
nil

> (idfn '(a b c))
(a b c)

> (idfn \bel)
\bel

> (idfn 'x)
x

