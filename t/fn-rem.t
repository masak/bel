#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (rem \a "abracadabra")
"brcdbr"

> (rem 'b '(a b c b a b))
(a c a)

> (rem 'b '(a c a))
(a c a)

> (rem 'x nil)
nil

> (rem '() '(a () c () a ()))
(a c a)

> (rem '(z) '(a (z) c) id)
(a (z) c)

> (rem 'x '((a) (x y) (b) (x)) caris)
((a) (b))

