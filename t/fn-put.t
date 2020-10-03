#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (put 'a 'x nil)
((a . x))

> (put 'a 'x '((b . y) (c . z)))
((a . x) (b . y) (c . z))

> (put 'a 'x '((b . y) (a . w)))
((a . x) (b . y))

> (put (join) 'x (list '(b . y) (cons (join) 'w)))
(((nil) . x) (b . y))

> (put (join) 'x (list '(b . y) (cons (join) 'w)) id)
(((nil) . x) (b . y) ((nil) . w))

> (set p (join))
(nil)

> (put p 'x (list '(b . y) (cons p 'w)) id)
(((nil) . x) (b . y))

