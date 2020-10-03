#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (rpart (lit num (+ nil (t)) (+ nil (t))))
0

> (rpart (lit num (+ nil (t)) (+ (t) (t))))
0

> (rpart (lit num (+ (t) (t)) (+ nil (t))))
1

> (rpart (lit num (+ (t t) (t t t)) (+ (t) (t t t t))))
2/3

