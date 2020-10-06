#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(where (car '(x . y))))
((x . y) a)

> (bel '(where (cdr '(z . w))))
((z . w) d)

The following two tests would probably work, but they are too slow.
Even `(bel 'k!a)` is too slow right now. Maybe later.

SKIP: > (bel '(where ((lit tab (a . 1)) 'a)))
SKIP: ((a . 1) 'd)

SKIP: > (bel '(where ((lit tab (a . 1)) 'b)))
SKIP: ((b) 'd)

