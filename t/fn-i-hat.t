#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (i^ i0 i0)
(t)

> (i^ i0 i1)
nil

> (i^ i1 i0)
(t)

> (i^ i1 i2)
(t)

> (i^ i10 i1)
(t t t t t t t t t t)

> (i^ i2 '(t t t))
(t t t t t t t t)

