#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set x1 (cons `(,smark bind (x . 1)) nil)
       x2 (cons `(,smark bind (x . 2)) nil)
       y1 (cons `(,smark bind (y . 1)) nil))
!IGNORE: result of assignment

> (binding 'x nil)
nil

> (binding 'x (list y1))
nil

> (binding 'x (list x2))
(x . 2)

> (binding 'x (list y1 x2))
(x . 2)

> (binding 'x (list x2 y1))
(x . 2)

> (binding 'x (list x1 x2))
(x . 1)

