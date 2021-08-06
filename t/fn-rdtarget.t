#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (rdtarget '("") i10 "1" (join) nil)
!ERROR: missing-target

> (rdtarget '("x") i10 "1" (join) nil)
!ERROR: bad-target

> (set c (join))
(nil)

> (rdtarget '("(foo bar)") i10 "1" c nil)
(#1=(foo bar) (("1" . #1)))

> (rdtarget '("(quux)") i10 "2" (join) '(("1" foo bar)))
(#1=(quux) (("2" . #1) ("1" foo bar)))

