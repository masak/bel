#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> ((macro (v) v) 'b)
b

> ((macro (v) `(cons ,v 'a)) 'b)
(b . a)

> ((fn (x)
    ((macro (v) `(cons ,v 'a)) x)) 'b)
(b . a)

