#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (real (lit num (+ nil (t)) (+ nil (t))))
t

> (real (lit num (+ nil (t)) (+ (t) (t))))
nil

> (real (lit num (+ (t) (t)) (+ nil (t))))
t

> (real (lit num (+ (t t) (t t t)) (+ (t) (t t t t))))
nil

