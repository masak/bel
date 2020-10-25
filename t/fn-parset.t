#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (parset "foo|bar" i10)
(t foo bar)

> (parset "foo|bar|baz" i10)
!ERROR: multiple-bars

> (parset "a:b|c.d" i10)
(t (compose a b) (c d))

> (parset "foo|" i10)
!ERROR: bad-tspec

> (parset "|bar" i10)
!ERROR: bad-tspec

