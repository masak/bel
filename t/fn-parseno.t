#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (parseno "~car" i10)
(compose no car)

> (parseno "~" i10)
no

> (parseno "~5" i10)
(compose no 5)

> (parseno "1+3i" i10)
1+3i

> (parseno "a-symbol" i10)
a-symbol

> (type (parseno "a-symbol" i10))
symbol

