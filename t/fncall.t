#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> ((lit clo nil (x) (id x nil)) nil)
t

> ((lit clo nil (x) (id x nil)) t)
nil

> ('y 'z)
!ERROR: cannot-apply

