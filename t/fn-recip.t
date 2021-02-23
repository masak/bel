#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (recip (lit num (+ (t) (t)) (+ nil (t))))
1

> (recip (lit num (- (t) (t)) (+ nil (t))))
-1

> (recip (lit num (+ (t t) (t)) (+ nil (t))))
1/2

> (recip (lit num (- (t t t) (t)) (+ nil (t))))
-1/3

> (recip (lit num (+ nil (t)) (+ (t) (t))))
-i

> (recip (lit num (+ nil (t)) (- (t) (t))))
+i

> (recip (lit num (+ (t t t) (t)) (+ (t t t t) (t))))
3/25-4/25i

> (recip 0)
!ERROR: mistype

