#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (runs is.1 '(1 1 0 0 0 1 1 1 0))
((1 1) (0 0 0) (1 1 1) (0))

> (runs is.1 '())
nil

> (runs is.1 '(1))
((1))

> (runs is.1 '(0))
((0))

> (runs is.1 '(1 0))
((1) (0))

> (runs is.1 '(0 1))
((0) (1))

> (runs is.1 '(1) nil)
(nil (1))

> (runs is.1 '(1) t)
((1))

> (runs is.1 '(0) nil)
((0))

> (runs is.1 '(0) t)
(nil (0))

> (runs is.1 '(1 0) nil)
(nil (1) (0))

> (runs is.1 '(1 0) t)
((1) (0))

> (runs is.1 '(0 1) nil)
((0) (1))

> (runs is.1 '(0 1) t)
(nil (0) (1))

