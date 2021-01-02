#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (intchar nil)
\0

> (set n7 '(t t t t t t t))
!IGNORE: output of set

> (intchar n7)
\7

> (set n10 '(t t t t t t t t t t))
!IGNORE: output of set

> (intchar n10)
\a

> (set n14 '(t t t t t t t t t t t t t t))
!IGNORE: output of set

> (intchar n14)
\e

> (set n16 '(t t t t t t t t t t t t t t t t))
!IGNORE: output of set

> (intchar n16)
nil

