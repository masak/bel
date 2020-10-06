#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (srnum (list '+ i1 i1))
(t)

> (srnum (list '- i1 i1))
(t)

> (srnum (list '+ i0 i1))
nil

> (srnum (list '+ i2 i1))
(t t)

> (srnum (list '+ '(t t t) i1))
(t t t)

> (srnum (list '- i2 '(t t t)))
(t t)

> (srnum (list '+ i16 i0))
(t t t t t t t t t t t t t t t t)

