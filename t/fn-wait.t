#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (def popx ()
    (let (xa . xd) x
      (set x xd)
      xa))
!IGNORE: result of definition

> (set x '(nil nil a b c))
(nil nil a b c)

> (len x)
5

> (wait popx)
a

> (len x)
2

