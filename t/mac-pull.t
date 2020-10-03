#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (let L '(a b c b d)
    (pull 'b L))
(a c d)

You can `pull` from the inside of a list!

> (set L '(a b a c a a d))
(a b a c a a d)

> (pull 'a (cdr L))
(b c d)

> L
(a b c d)

> (pull 'z L)
(a b c d)

> (set L '(a))
(a)

> (pull 'a L)
nil

> (bind L '(g h g i g)
    (pull 'g L))
(h i)

> (def f ()
    (pull 'h L))
!IGNORE: result of definition

> (bind L '(g h h h i)
    (f))
(g i)

> (set q '(b))
(b)

> (let L `((a) ,q)
    (pull q L))
((a))

> (let L `((a) ,q)
    (pull '(b) L id))
((a) (b))

> (let L `((a) ,q)
    (pull q L id))
((a))

