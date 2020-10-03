#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (i< i0 i0)
nil

> (i< i0 i1)
(t)

> (i< i1 i2)
(t)

> (i< i10 i16)
(t t t t t t)

> (i< i16 i10)
nil

