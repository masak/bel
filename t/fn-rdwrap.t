#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (rdwrap '("") 'quote i10 nil)
!ERROR: missing-expression

> (rdwrap '("foo") 'quote i10 nil)
((quote foo) nil)

> (rdwrap '("foo") 'quote i10 '(bar))
((quote foo) (bar))

