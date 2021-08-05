#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set d '(nil))
(nil)

> (set dd (list d d))
(#1=(nil) #1)

> (set e '(nil))
(nil)

> (set (cdr e) e)
#1=(nil . #1)

> e
#1=(nil . #1)

> (set L '(1 2 3))
(1 2 3)

> (set K '(4 5 6))
(4 5 6)

> (set (cdr (cddr K)) K)
#1=(4 5 6 . #1)

> (set (cdr (cddr L)) K)
#1=(4 5 6 . #1)

> L
(1 2 3 . #1=(4 5 6 . #1))

> (set A1 '(hi there))
(hi there)

> (set A2 '(there hi))
(there hi)

> (set (cdr A1) A2)
(there hi)

> (set (cdr A2) A1)
#1=(hi there . #1)

> A2
#1=(there hi . #1)

> (set R '(x))
(x)

> (set (car R) R)
#1=(#1)

> R
#1=(#1)

