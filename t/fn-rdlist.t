#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (rdlist '("   ") \) i10 nil)
!ERROR: unterminated-list

> (rdlist '("a . b)") \) i10 nil)
!ERROR: ('unboundb rddot)

> (rdlist '("a b c)") \) i10 nil)
((a b c) nil)

> (rdlist '(")") \) i10 nil)
(nil nil)

