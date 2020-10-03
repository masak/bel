#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> `x
x

> `(y z)
(y z)

> ((fn (x) `(a ,x)) 'b)
(a b)

> ((fn (y) `(,y d)) 'c)
(c d)

> ((fn (x) `(a . ,x)) 'b)
(a . b)

> ((fn (y) `(,y . d)) 'c)
(c . d)

> ((fn (x) `(a ,@x)) '(b1 b2 b3))
(a b1 b2 b3)

> ((fn (y) `(,@y d)) '(c1 c2 c3))
(c1 c2 c3 d)

> ((fn (y) `(,@y . d)) '(c1 c2 c3))
(c1 c2 c3 . d)

> ,x
!ERROR: comma-outside-backquote

> ((fn (x) ,x) 'a)
!ERROR: comma-outside-backquote

> (nil ,@x)
!ERROR: comma-at-outside-backquote

> ((fn (x) (nil ,@x)) 'a)
!ERROR: comma-at-outside-backquote

> `,@x
!ERROR: comma-at-outside-list

> ((fn (x) `,@x) 'a)
!ERROR: comma-at-outside-list

