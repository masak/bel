#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (= (randlen 0) nil)
t

> (<= 0 (randlen 2) 3)
t

> (<= 0 (randlen 3) 7)
t

> (<= 0 (randlen 4) 15)
t

