#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (pairwise id nil)
t

> (pairwise id '(a))
t

> (pairwise id '(a a))
t

> (pairwise id '(a b))
nil

> (set L (nof 3 (join)))
((nil) (nil) (nil))

> (pairwise id L)
nil

> (pairwise = L)
t

> (let p (join)
    (pairwise id `(,p ,p ,p)))
t

