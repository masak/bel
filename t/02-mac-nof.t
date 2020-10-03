#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (nof 5 'hi)
(hi hi hi hi hi)

> (nof 3 '(s))
((s) (s) (s))

> (nof 0 '(s))
nil

> (let L (nof 3 '(s))
    (= (1 L) (2 L)))
t

> (let L (nof 3 '(s))
    (id (1 L) (2 L)))
t

> (let n 0
    (nof 4 (++ n)))
(1 2 3 4)

