#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (hug '(a b c d e))
((a b) (c d) (e))

> (with (a 1 b) (list a b))
(1 nil)

> (set x 1
       y)
t

> x
1

> y
t

> (tem t1 f1 nil f2)
!ERROR: underargs

> (tem t2 f1 nil)
!IGNORE: result of template declaration

> (make t2 f1 1 f2)
!ERROR: underargs

