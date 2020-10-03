#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (def c1 (x)
    (case x
      a 'm))
!IGNORE: result of definition

> (c1 'a)
m

> (c1 'b)
nil

> (def c2 (x)
    (case x
      a 'm
        'n))
!IGNORE: result of definition

> (c2 'a)
m

> (c2 'b)
n

> (def c3 (x)
    (case x
      a 'm
      b 'n))
!IGNORE: result of definition

> (c3 'a)
m

> (c3 'b)
n

> (c3 'c)
nil

> (def c4 (x)
    (case x
      a 'm
      b 'n
        'o))
!IGNORE: result of definition

> (c4 'a)
m

> (c4 'b)
n

> (c4 'c)
o

