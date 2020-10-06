#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (numr (lit num (+ nil (t)) (+ nil (t))))
(+ nil (t))

> (numr (lit num (+ nil (t)) (+ (t) (t))))
(+ nil (t))

> (numr (lit num (+ (t) (t)) (+ nil (t))))
(+ (t) (t))

> (numr (lit num (+ (t t) (t t t)) (+ (t) (t t t t))))
(+ (t t) (t t t))

