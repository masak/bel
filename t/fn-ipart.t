#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (ipart (lit num (+ nil (t)) (+ nil (t))))
0

> (ipart (lit num (+ nil (t)) (+ (t) (t))))
1

> (ipart (lit num (+ (t) (t)) (+ nil (t))))
0

> (ipart (lit num (+ (t t) (t t t)) (+ (t) (t t t t))))
1/4

