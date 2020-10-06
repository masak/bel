#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (array nil)
nil

> (array nil 0)
0

> (array nil 'x)
x

> (array '(3) 0)
(lit arr 0 0 0)

> (array '(0) 'x)
(lit arr)

> (set L0 0
       L1 `(lit arr ,L0 ,L0)
       L2 `(lit arr ,L1 ,L1)
       L3 `(lit arr ,L2 ,L2))
!IGNORE: result of assignment

> (= (array '(2 2) 0) L2)
t

> (= (array '(2 2 2) 0) L3)
t

