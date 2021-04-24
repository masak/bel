#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(quote a))
a

> (bel '(quote))
!ERROR: bad-form

> (bel '(quote a b))
!ERROR: bad-form

> (bel '(quote a b nil))
!ERROR: bad-form

