#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (dedup "abracadabra")
"abrcd"

> (dedup '(1 2 2 2 3 1 4 2))
(1 2 3 4)

> (dedup '((a) (b) (a)))
((a) (b))

> (dedup '((a) (b) (a)) id)
((a) (b) (a))

> (let p '(a)
    (dedup `(,p (b) ,p) id))
((a) (b))

> (dedup '(7 3 0 9 2 4 1) >=)
(7 9)

