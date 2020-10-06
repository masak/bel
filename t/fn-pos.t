#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (pos 'b '(a b c))
2

> (pos 'x '(w y z))
nil

> (pos 'b '(a b c b b))
2

> (pos '() '(n n () n))
3

> (set p '(x))
(x)

> (pos p '(n n (x) n))
3

> (pos p '(n n (x) n) id)
nil

> (pos p `(n n ,p n) id)
3

