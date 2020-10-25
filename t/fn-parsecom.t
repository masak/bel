#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (parsecom "~car" i10)
(compose no car)

> (parsecom "~" i10)
no

> (parsecom "~5" i10)
(compose no 5)

> (parsecom "1+3i" i10)
1+3i

> (parsecom "a-symbol" i10)
a-symbol

> (type (parsecom "a-symbol" i10))
symbol

> (parsecom "car:cdr" i10)
(compose car cdr)

> (parsecom "car:cdr:cdr" i10)
(compose car cdr cdr)

> (parsecom ":" i10)
(compose)

