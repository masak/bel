#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (lastcdr nil)
nil

> (lastcdr '(a))
(a)

> (lastcdr '(a b))
(b)

> (lastcdr '(a b c))
(c)

> (let p '(c)
    (id (lastcdr (cons 'a 'b
                 p))
        p))
t

