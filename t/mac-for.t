#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (let L nil
    (for n 1 5
      (push n L))
    L)
(5 4 3 2 1)

> (let L nil
    (for n 3 3
      (push n L))
    L)
(3)

> (let L nil
    (for n 4 1
      (push n L))
    L)
nil

