#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set s '("2+3i and some other stuff"))
!IGNORE: result of assignment

> (rdword s (rdc s) i10)
2+3i

> s
(" and some other stuff")

> (rdword nil \a i10)
!ERROR: ('unboundb bitc)

