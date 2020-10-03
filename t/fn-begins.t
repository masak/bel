#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (begins nil nil)
t

> (begins '(a b c) nil)
t

> (begins '(a b c) '(a))
t

> (begins '(a b c) '(x))
nil

> (begins '(a b c) '(a b))
t

> (begins '(a b c) '(a y))
nil

> (begins '(a b c) '(a b c))
t

> (begins '(a b c) '(a b z))
nil

> (set p (join))
(nil)

> (begins `(,p) `(,p))
t

> (begins `(,p) `(,(join)))
t

> (begins `(,p) `(,p) id)
t

> (begins `(,p) `(,(join)) id)
nil

