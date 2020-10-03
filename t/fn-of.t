#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (list (car '(a b)) (car '(c d)) (car '(e f)))
(a c e)

> ((of list car) '(a b) '(c d) '(e f))
(a c e)

> (def double (x)
    (list x x))
!IGNORE: result of definition

> ((of list double) 'a 'b)
((a a) (b b))

> ((of append double) 'a 'b 'c)
(a a b b c c)

> ((of join con.t) 'a 'b)
(t . t)

