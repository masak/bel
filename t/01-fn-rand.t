#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (<= 0 (rand 2) 1)
t

> (<= 0 (rand 6) 5)
t

> (<= 0 (rand 11) 10)
t

> (rand 0)
!ERROR: mistype

