#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (fuse idfn '((a b) (c d) (e f)))
(a b c d e f)

> (fuse list '(a b c) '(1 2 3))
(a 1 b 2 c 3)

> (fuse list '(a b c) '(1 2))
(a 1 b 2)

> (fuse join)
nil

> (fuse car '(a b c) '(1 2 3))
!ERROR: car-on-atom

