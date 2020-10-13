#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (parseint "" i10)
nil

> (parseint "" i0)
nil

> (parseint "3" i10)
(t t t)

> (parseint "7" i10)
(t t t t t t t)

> (parseint "f" i16)
(t t t t t t t t t t t t t t t)

> (parseint "11" i10)
(t t t t t t t t t t t)

> (parseint "11" i16)
(t t t t t t t t t t t t t t t t t)

> (parseint "00" i10)
nil

