#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set c1 `((+ ,i1 ,i1) (+ ,i0 ,i1))
       c2 `((- ,i1 ,i1) (+ ,i0 ,i1))
       c0 `((+ ,i0 ,i1) (+ ,i0 ,i1))
       c3 `((+ ,i0 ,i1) (+ ,i1 ,i1))
       c4 `((+ ,i2 (t t t)) (+ ,i1 ,i1))
       c5 `((+ ,i1 (t t t)) (- ,i1 ,i1)))
!IGNORE: result of assignment

> (c+ c1 c1)
((+ (t t) (t)) (+ nil (t)))

> (c+ c1 c2)
((- nil (t)) (+ nil (t)))

> (c+ c0 c0)
((+ nil (t)) (+ nil (t)))

> (c+ c3 c3)
((+ nil (t)) (+ (t t) (t)))

> (c+ c4 c5)
((+ (t t t t t t t t t) (t t t t t t t t t)) (- nil (t)))

