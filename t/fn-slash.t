#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (/)
1

> (/ 5)
5

> (set n1 (lit num (+ (t) (t)) (+ nil (t)))
       m1 (lit num (- (t) (t)) (+ nil (t)))
       z1 (lit num (+ nil (t)) (+ (t t t) (t)))
       z2 (lit num (- (t) (t t)) (+ nil (t)))
       z3 (lit num (+ nil (t)) (- (t t) (t t t))))
!IGNORE: result of assignment

> (/ n1 n1)
1

> (/ n1 m1)
-1

> (/ n1 z1)
-1/3i

> (/ z2 z3)
-3/4i

> (/ 1 1)
1

> (/ 1 -1)
-1

> (/ 1 +3i)
-1/3i

> (/ -1/2 -2/3i)
-3/4i

> (/ 1 0)
!ERROR: mistype

