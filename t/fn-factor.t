#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set i2 '(t t)
       i3 '(t t t)
       i4 '(t t t t)
       i5 '(t t t t t)
       i6 '(t t t t t t)
       i7 '(t t t t t t t))
!IGNORE: result of assignment

> (= (factor i2) (list i2))
t

> (= (factor i3) (list i3))
t

> (= (factor i4) (list i2 i2))
t

> (= (factor i5) (list i5))
t

> (= (factor i6) (list i2 i3))
t

> (= (factor i7) (list i7))
t

