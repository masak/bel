#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (cons 'a nil)
(a)

> (cons 'a)
a

> (cons 'a 'b)
(a . b)

> (cons)
nil

> (cons 'a 'b 'c '(d e f))
(a b c d e f)

> (let p '(b)
    (id (cdr:cons 'a p) p))
t

