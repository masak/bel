#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set L '(a b c))
(a b c)

> (pop L)
a

> L
(b c)

> (set L '(d e f))
(d e f)

> (pop (cddr L))
f

> L
(d e)

> (pop L)
d

> (pop L)
e

> L
nil

> (def f ()
    (pop L))
!IGNORE: result of definition

> (bind L '(g h i)
    (f)
    L)
(h i)

