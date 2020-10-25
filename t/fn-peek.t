#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (peek '("hello"))
\h

> (peek '(nil))
nil

> (peek nil)
!ERROR: ('unboundb bitc)

