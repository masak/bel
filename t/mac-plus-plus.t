#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (let x 1
    (++ x))
2

> (let x 1.5
    (++ x))
5/2

> (let x -3+i
    (++ x))
-2+i

> (set x 1)
1

> (++ x)
2

> x
2

> (++ x 3)
5

> x
5

> (set L '(1 1 1))
(1 1 1)

> (++ (cadr L))
2

> L
(1 2 1)

> (bind f6ac4d 2
    (++ f6ac4d)
    f6ac4d)
3

> (bind f6ac4d 3
    (++ f6ac4d 3)
    f6ac4d)
6

> (let L '(1 2 3)
    (++ (find is.2 L))
    L)
(1 3 3)

> (++ (find [= _ 0] '(1 2 3)))
!ERROR: unfindable

> (let kvs '((a . 1)
             (b . 2)
             (c . 3))
    (++ (cdr:get 'b kvs))
    kvs)
((a . 1) (b . 3) (c . 3))

> (let kvs '(((a) . 1)
             ((b) . 2)
             ((c) . 3))
    (++ (cdr:get '(b) kvs))
    kvs)
(((a) . 1) ((b) . 3) ((c) . 3))

