#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set n1 (lit num (+ (t) (t)) (+ nil (t)))
       n2 (lit num (- (t) (t)) (+ nil (t)))
       n3 (lit num (+ nil (t)) (+ (t t t) (t)))
       n4 (lit num (- (t) (t t)) (+ nil (t)))
       n5 (lit num (+ nil (t)) (- (t t) (t t t)))
       n6 (lit num (+ (t) (t t)) (- (t t) (t t t)))
       n7 (lit num (- (t) (t t)) (+ (t t) (t t t))))
!IGNORE: result of assignment

> (-)
0

> (- n1 n1)
0

> (- n1 n2)
2

> (- n1 (lit num (+ nil (t)) (+ (t t t) (t))))
1-3i

> (- n4 n5)
-1/2+2/3i

> (- n6 n7)
1-4/3i

> (- 1 1)
0

> (- 1 -1)
2

> (- 1 +3i)
1-3i

> (- -1/2 -2/3i)
-1/2+2/3i

> (- 1/2-2/3i -1/2+2/3i)
1-4/3i

> (- 4 3 2 1)
-2

