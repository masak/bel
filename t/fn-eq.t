#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (= '() '())
t

> (= 'x 'x)
t

> (= 'x 'y)
nil

> (= 'x '(x))
nil

> (= '(a b c) '(a b c))
t

> (= '(a b d) '(a b c))
nil

> (= '(a b) '(a b c))
nil

> (= '(a b c) '(a b))
nil

> (= '(a b (x y)) '(a b (x y)))
t

> (= '(a b (x y)) '(a b (x z)))
nil

