#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (buildnum '(+ (t) (t)) '(+ nil (t)))
1

> (buildnum '(+ (t t) (t t)) '(+ nil (t)))
1

> (set i2i2 '(+ (t t) (t t))
       i4i6 '(+ (t t t t) (t t t t t t))
       i0i1 '(+ nil (t)))
!IGNORE: result of assignment

> (srnum:numr (buildnum i2i2 i0i1))
(t)

> (srnum:numr (buildnum i4i6 i0i1))
(t t)

