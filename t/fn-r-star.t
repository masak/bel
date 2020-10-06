#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (r* `(,i1 ,i1) `(,i1 ,i1))
((t) (t))

> (r* `(,i0 ,i1) `(,i0 ,i1))
(nil (t))

> (r* `(,i2 ,i1) `(,i2 ,i1))
((t t t t) (t))

> (r* `(,i1 ,i2) `(,i1 ,i2))
((t) (t t t t))

> (r* `(,i2 (t t t)) `((t t t) ,i2))
((t t t t t t) (t t t t t t))

> (r* `(,i2 ,i0) `((t t t) ,i2))
((t t t t t t) nil)

