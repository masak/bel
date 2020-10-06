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
       sr6 (list '+ i1 i2)
       sr7 (list '+ '(t t t) i2))
!IGNORE: result of assignment

> (sr+ sr1 sr1)
(+ (t t) (t))

> (sr+ sr1 sr2)
(- nil (t))

> (sr+ sr3 sr3)
(+ nil (t))

> (sr+ sr4 sr4)
(+ (t t t t) (t))

> (sr+ sr1 sr5)
(- (t) (t))

> (sr+ sr6 sr6)
(+ (t t t t) (t t t t))

> (sr+ (list '+ i2 '(t t t)) sr7)
(+ (t t t t t t t t t t t t t) (t t t t t t))

> (sr+ (list '- i2 '(t t t)) sr7)
(+ (t t t t t) (t t t t t t))

> (sr+ (list '+ i2 i0) sr7)
(+ (t t t t) nil)

