#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (dups nil)
nil

> (dups '(a b c))
nil

> (dups '(a b b c))
(b)

> (dups '(a nil b c nil))
(nil)

> (dups '(1 2 3 4 3 2))
(2 3)

> (dups "abracadabra")
"abr"

> (dups '(1 2 2 2 3 1 4 2))
(1 2)

> (dups '((a) (b) (a)))
((a))

> (dups '((a) (b) (a)) id)
nil

> (dups '(7 3 0 9 2 4 1) >=)
(7 3 0)

