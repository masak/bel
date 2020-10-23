#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (rddot '("") \) i10 nil nil)
!ERROR: unterminated-list

> (rddot '(" ") \) i10 nil nil)
!ERROR: missing-car

> (rddot '(" foo)") \) i10 nil '(bar))
!ERROR: ('unboundb hard-rdex)

> (rddot '(" foo bar)") \) i10 nil '(bar))
!ERROR: ('unboundb hard-rdex)

> (rddot '("2)") \) i10 nil nil)
((1/5) nil)

> (rddot '("2)") \) i10 nil '(bar))
((bar 1/5) nil)

