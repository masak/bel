#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (let f (fn () d) (f))
!ERROR: (unboundb d)

> (let f (fn () d) (bind d 'hai (f)))
hai

> (bind d 'yes
    d)
yes

> (bind d 'yes
    'no
    'but
    d)
yes

> (bind d 'one
    (cons (bind d 'two d) d))
(two . one)

Dynamic variables trump lexical variables, no matter how they nest.

> (let v 'lexical
    (bind v 'dynamic v))
dynamic

> (bind v 'dynamic
    (let v 'lexical v))
dynamic

