#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (inv (lit num (+ nil (t)) (+ nil (t))))
0

> (inv (lit num (+ nil (t)) (+ (t) (t))))
-i

> (inv (lit num (+ (t) (t)) (+ nil (t))))
-1

> (inv (lit num (+ (t t) (t t t)) (+ (t) (t t t t))))
-2/3-1/4i

