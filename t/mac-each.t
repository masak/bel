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
(#1=(2) #2=(3 . #1) (4 . #2))

> L
(4 3 2)

> (set L '())
nil

> (each n '(1 2 3)
    (set L (append (list inc.n) L nil)))
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
(#1=(a) #2=(b . #1) (c . #2))

> L
(c b a)

> (set L nil)
nil

> (each e '(a b c)
    (set L (append (list e) L nil)))
((a) (b a) (c b a))

> L
(c b a)

