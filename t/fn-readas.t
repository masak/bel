#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (tem point x 0 y 0)
!IGNORE: result of template definition

> (readas 'point '("(lit tab)"))
(lit tab (x . 0) (y . 0))

> (readas 'point '("(lit tab (x . 1) (y . 2))"))
(lit tab (x . 1) (y . 2))

> (readas 'point '("(lit tab (x . 1) (z . 1))"))
(lit tab (x . 1) (y . 0))

