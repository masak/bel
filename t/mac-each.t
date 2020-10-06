#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set L '())
nil

> (each n '(1 2 3)
    (push (inc n) L))
((2) (3 2) (4 3 2))

> L
(4 3 2)

> (set L '())
nil

> (each n '()
    (push (inc n) L))
nil

> L
nil

> (set L '((a) (b) (c)))
((a) (b) (c))

> (each e L
    (xar e 'z))
(z z z)

> L
((z) (z) (z))

> (set L nil)
nil

> (each e '(a b c)
    (push e L))
((a) (b a) (c b a))

> L
(c b a)

