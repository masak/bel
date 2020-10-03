#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (srinv (list '+ i1 i1))
(- (t) (t))

> (srinv (list '+ i0 i1))
(+ nil (t))

> (srinv (list '- i0 i1))
(+ nil (t))

> (srinv (list '+ i2 i1))
(- (t t) (t))

> (srinv (list '+ i1 i2))
(- (t) (t t))

> (srinv (list '- i1 i2))
(+ (t) (t t))

> (srinv (list '+ i2 '(t t t)))
(- (t t) (t t t))

> (srinv (list '- '(t t t) i2))
(+ (t t t) (t t))

> (srinv (list '+ i2 i10))
(- (t t) (t t t t t t t t t t))

