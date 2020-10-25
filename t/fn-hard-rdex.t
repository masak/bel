#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (hard-rdex '("foo") i10 nil 'no-message)
(foo nil)

> (hard-rdex '("") i10 nil 'unterminated-list)
!ERROR: unterminated-list

