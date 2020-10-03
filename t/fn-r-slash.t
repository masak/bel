#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (r/ (list i1 i1) (list i1 i1))
((t) (t))

> (r/ (list i0 i1) (list i0 i1))
(nil nil)

> (r/ (list i2 i1) (list i2 i1))
((t t) (t t))

> (r/ (list i1 i2) (list i1 i2))
((t t) (t t))

> (r/ (list i2 '(t t t)) (list '(t t t) i2))
((t t t t) (t t t t t t t t t))

> (r/ (list i2 i0) (list '(t t t) i2))
((t t t t) nil)

