#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set sr1 (list '+ i1 i1)
       sr2 (list '- i1 i1)
       sr3 (list '+ i0 i1)
       sr4 (list '+ i2 i1)
       sr5 (list '- i2 i1)
       sr6 (list '+ i1 i2))
!IGNORE: result of assignment

> (sr< sr1 sr1)
nil

> (sr< sr1 sr2)
nil

> (sr< sr3 sr3)
nil

> (sr< sr4 sr4)
nil

> (sr< sr1 sr5)
nil

> (sr< sr5 sr1)
t

> (sr< sr5 sr2)
(t)

> (sr< sr6 sr1)
(t)

> (sr< (list '+ i2 '(t t t)) (list '+ '(t t t) i2))
(t t t t t)

> (sr< (list '- i2 '(t t t)) (list '+ '(t t t) i2))
t

> (sr< (list '+ i2 i0) (list '+ i2 i2))
nil

