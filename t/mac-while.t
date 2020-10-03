#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (with (x '(a b c)
         L '())
    (while (pop x)
      (push x L))
    L)
(nil (c) (b c))

> (with (x '()
         L '())
    (while (pop x)
      (push x L))
    L)
nil

