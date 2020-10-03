#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (simplify '(+ nil (t t t)))
(+ nil (t))

> (simplify '(+ nil (t)))
(+ nil (t))

> (simplify '(+ nil nil))
(+ nil (t))

> (simplify '(+ (t t t t t t) (t t t t)))
(+ (t t t) (t t))

> (simplify '(+ (t t t t t t) (t t t)))
(+ (t t) (t))

