#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (caris nil nil)
nil

> (caris '(a b c) 'a)
t

> (caris '(a b c) 'b)
nil

> (set p '(x y z))
(x y z)

> (caris '((x y z) b c) p)
t

> (caris '((x y z) b c) p id)
nil

> (caris `(,p b c) p id)
t

