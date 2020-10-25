#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (charint \3)
(t t t)

> (charint \7)
(t t t t t t t)

> (charint \f)
(t t t t t t t t t t t t t t t)

