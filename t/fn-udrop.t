#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (udrop nil nil)
nil

> (udrop nil '(a b c))
(a b c)

> (udrop '(x) '(a b c))
(b c)

If the first list is as long as or longer than the second list, you
get `nil` back.

> (udrop '(x y z w) '(a b c))
nil

