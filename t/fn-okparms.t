#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (okparms nil)
t

> (okparms 'args)
t

> (okparms 't)
nil

> (okparms 'o)
nil

> (okparms 'apply)
nil

> (okparms (uvar))
t

> (okparms '(t x int))
t

> (okparms '(t x int y))
nil

> (okparms '(t x int))
t

> (okparms '(t x int y))
nil

> (okparms '(o y 0))
nil

> (okparms '(o y))
nil

> (okparms '(o y (+ 2 2)))
nil

> (okparms '((o y 0)))
t

> (okparms '((o y 0 x)))
nil

> (okparms '((o y)))
t

> (okparms '((o y (+ 2 2))))
t

> (okparms '(a b))
t

> (okparms '(a (o b)))
t

> (okparms '(a (o b) c))
t

> (okparms '(a (o b 0) c))
t

> (okparms '(a (o b 0 1) c))
nil

> (okparms '(a . rest))
t

> (okparms '(a b . rest))
t

> (okparms '(a (b c) d))
t

> (okparms '(a (b . rest) d))
t

