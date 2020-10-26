#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (apply join '(a b))
(a . b)

> (apply join 'a '(b))
(a . b)

> (apply no '(nil))
t

> (apply no '(t))
nil

> (apply cons '(a b c (d e f)))
(a b c d e f)

> (apply cons '())
nil

> (map apply (list (fn () 'x) (fn () 'y)))
(x y)

