#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set x 'foo)
foo

> x
foo

> (set y)
t

> y
t

> (set x 'foo
       x 'bar))
bar

> x
bar

> (set x 'foo y 'bar)
bar

> x
foo

> (let x 'hi
    (set x 'bye)
    x)
bye

> x
foo

> (bind f6ac4d 'hi
    (set f6ac4d 'bye)
    f6ac4d)
bye

> (let L '(a b (c d) e)
    (set (find pair L) 'cd)
    L)
(a b cd e)

> (set (find pair '(a b e)) 'z)
!ERROR: unfindable

> (let kvs '((a . 1)
             (b . 2)
             (c . 3))
    (set (cdr:get 'b kvs) 5)
    kvs)
((a . 1) (b . 5) (c . 3))

> (let kvs '((a . 1)
             (b . 2)
             (c . 3))
    (set (get 'd kvs) 5))
!ERROR: unfindable

> (let kvs '(((a) . 1)
             ((b) . 2)
             ((c) . 3))
    (set (cdr:get '(b) kvs) 5)
    kvs)
(((a) . 1) ((b) . 5) ((c) . 3))

> (let kvs '(((a) . 1)
             ((b) . 2)
             ((c) . 3))
    (set (get '(b) kvs id) 5))
!ERROR: unfindable

