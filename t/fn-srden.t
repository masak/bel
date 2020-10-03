#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (srden (list '+ i1 i1))
(t)

> (srden (list '- i1 i1))
(t)

> (srden (list '+ i0 i1))
(t)

> (srden (list '+ i2 i1))
(t)

> (srden (list '+ '(t t t) i1))
(t)

> (srden (list '- i2 '(t t t)))
(t t t)

> (srden (list '+ i16 i0))
nil

