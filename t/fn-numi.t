#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (numi (lit num (+ nil (t)) (+ nil (t))))
(+ nil (t))

> (numi (lit num (+ nil (t)) (+ (t) (t))))
(+ (t) (t))

> (numi (lit num (+ (t) (t)) (+ nil (t))))
(+ nil (t))

> (numi (lit num (+ (t t) (t t t)) (+ (t) (t t t t))))
(+ (t) (t t t t))

