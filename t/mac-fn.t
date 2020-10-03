#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> ((fn (x) (list x x)) 'a)
(a a)

> ((fn (x y) (list x y)) 'a 'b)
(a b)

> ((fn () (list 'a 'b 'c)))
(a b c)

> ((fn (x) ((fn (y) (list x y)) 'g)) 'f)
(f g)

If there are several expressions in a function, the result of the whole
function call is the value of the last expression.

> ((fn () 'irrelevant 'relevant))
relevant

Side effects of the expressions prior to the last still run, in order.

> ((fn () (car 'atom) 'never))
!ERROR: car-on-atom

