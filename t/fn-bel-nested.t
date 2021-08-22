#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (do
    (bel '(pr 1 \lf))
    (pr 2 \lf))
1
2
(2 \lf)

