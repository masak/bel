#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set x 1)
1

> (zap + x 1)
2

> x
2

> (set y "Be")
"Be"

> (zap append y "l")
"Bel"

> y
"Bel"

> (set L '(a b c))
(a b c)

> (zap (fn () 'z) (cadr L))
z

> L
(a z c)

> (set L '(a (b c) d))
(a (b c) d)

> (zap cdr (find pair L))
(c)

> L
(a (c) d)

> (bind f6ac4d 'hi
    (zap (fn () 'bye) f6ac4d)
    f6ac4d)
bye

> (set L '(a b e))
(a b e)

> (zap idfn (find pair '(a b e)))
!ERROR: 'unfindable

> (set kvs '((a . 1)
             (b . 2)
             (c . 3)))
((a . 1) (b . 2) (c . 3))

> (zap (fn () 5) (cdr:get 'b kvs))
5

> kvs
((a . 1) (b . 5) (c . 3))

> (zap idfn (get 'd kvs))
!ERROR: 'unfindable

> (set kvs '(((a) . 1)
             ((b) . 2)
             ((c) . 3)))
(((a) . 1) ((b) . 2) ((c) . 3))

> (zap (fn () 5) (cdr:get '(b) kvs))
5

> kvs
(((a) . 1) ((b) . 5) ((c) . 3))

> (zap (fn () 5) (get '(b) kvs id))
!ERROR: 'unfindable

