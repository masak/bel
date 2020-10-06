#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (i/ i0 i1)
(nil nil)

> (i/ i1 i2)
(nil (t))

> (i/ i10 i1)
((t t t t t t t t t t) nil)

> (i/ i2 i10)
(nil (t t))

> (i/ i16 '(t t t))
((t t t t t) (t))

