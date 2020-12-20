#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (eif v (car 'atom)
    'no
    'yes)
no

> (eif v (car '(1 2))
    'no
    'yes)
yes

> (eif v (car 'atom)
    v
    v)
car-on-atom

> (eif v (car '(1 2))
    v
    v)
1

