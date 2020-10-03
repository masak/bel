#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (let x 1
    (-- x))
0

> (let x 1.5
    (-- x))
1/2

> (let x -3+i
    (-- x))
-4+i

> (set x 1)
1

> (-- x)
0

> x
0

> (-- x 3)
-3

> x
-3

> (set L '(1 1 1))
(1 1 1)

> (-- (cadr L))
0

> L
(1 0 1)

> (bind f6ac4d 2
    (-- f6ac4d)
    f6ac4d)
1

> (bind f6ac4d 3
    (-- f6ac4d 3)
    f6ac4d)
0

> (let L '(1 2 3)
    (-- (find is.2 L))
    L)
(1 1 3)

> (-- (find [= _ 0] '(1 2 3)))
!ERROR: 'unfindable

> (let kvs '((a . 1)
             (b . 2)
             (c . 3))
    (-- (cdr:get 'b kvs))
    kvs)
((a . 1) (b . 1) (c . 3))

> (let kvs '(((a) . 1)
             ((b) . 2)
             ((c) . 3))
    (-- (cdr:get '(b) kvs))
    kvs)
(((a) . 1) ((b) . 1) ((c) . 3))

