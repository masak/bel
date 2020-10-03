#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set k (table '((z . 2)
                  (a . 1)
                  (c . d))))
!IGNORE: result of definition

> (tabrem k 'z)
((a . 1) (c . d))

> k
(lit tab (a . 1) (c . d))

