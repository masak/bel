#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (awhen nil)
nil

> (awhen 'a
    (list it 'b))
(a b)

> (awhen 'a
    (list 'b it)
    'c)
c

> (awhen nil
    (list 'b it)
    'c)
nil

