#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(list 'a (ccc (lit clo nil (c) 'b))))
(a b)

> (bel '(ccc))
!ERROR: bad-form

> (bel '(ccc a b))
!ERROR: bad-form

