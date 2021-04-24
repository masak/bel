#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(dyn d 2 d))
2

> (bel '(dyn))
!ERROR: bad-form

> (bel '(dyn v))
!ERROR: bad-form

> (bel '(dyn v a))
!ERROR: bad-form

> (bel '(dyn v a b c))
!ERROR: bad-form

