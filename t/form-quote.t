#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (quote)
!ERROR: bad-form

> (quote a)
a

> (quote 'a)
(quote a)

> (quote a b)
!ERROR: bad-form

> (quote a b nil)
!ERROR: bad-form

