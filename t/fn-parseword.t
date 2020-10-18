#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (parseword "2+3i" i10)
2+3i

> (parseword "." i10)
!ERROR: unexpected-dot

> (parseword "x|int" i10)
(t x int)

> (parseword "one.two" i10)
(one two)

> (parseword "one!two" i10)
(one (quote two))

> (parseword ".car" i10)
(upon car)

> (parseword "~car" i10)
(compose no car)

> (parseword "~" i10)
no

> (parseword "a-symbol" i10)
a-symbol

> (parseword "car:cdr" i10)
(compose car cdr)

> (parseword "car:cdr:cdr" i10)
(compose car cdr cdr)

> (parseword ":" i10)
(compose)

