#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (abs (lit num (+ nil (t)) (+ nil (t))))
0

> (abs (lit num (+ nil (t)) (+ (t) (t))))
0

> (abs (lit num (+ (t) (t)) (+ nil (t))))
1

> (abs (lit num (- (t) (t)) (+ nil (t))))
1

> (abs (lit num (+ (t t) (t t t)) (- (t) (t t t t))))
2/3

> (abs (lit num (- (t t) (t t t)) (+ (t) (t t t t))))
2/3

