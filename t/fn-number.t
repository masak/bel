#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (number '())
nil

> (number (lit))
nil

> (number (lit num))
nil

> (number (lit num (+ nil (t))))
nil

> (number (lit num (+ nil (t)) (+ nil)))
nil

> (number (lit num (+ nil (t)) (+ nil (t))))
t

> (number (lit num (+ (t) (t)) (+ nil (t))))
t

> (number (lit num (+ (t t) (t t t)) (+ (t t t) (t))))
t

