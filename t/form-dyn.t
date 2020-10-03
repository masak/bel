#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (let f (fn () d) (f))
!ERROR: ('unboundb d)

> (let f (fn () d)
    (dyn d 'hai (f)))
hai

> (dyn d 'yes d)
yes

Dynamic bindings can shadow each other on the value stack; as an
inner one goes out of scope, the next-outer one becomes visible again.

> (dyn d 'one
    (cons (dyn d 'two d) d))
(two . one)

Dynamic bindings trump lexical ones, regardless of how they nest.

> (let v 'lexical (dyn v 'dynamic v))
dynamic

> (dyn v 'dynamic (let v 'lexical v))
dynamic

