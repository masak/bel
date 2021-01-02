#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set n10 '(t t t t t t t t t t))
!IGNORE: output of set

> (rrep (list nil nil) n10)
"0/0"

> (set n1 '(t))
!IGNORE: output of set

> (set n7 '(t t t t t t t))
!IGNORE: output of set

> (rrep (list n7 n1) n10)
"7"

> (rrep (list n10 n7) n10)
"10/7"

> (set n14 '(t t t t t t t t t t t t t t))
!IGNORE: output of set

> (rrep (list n14 n1) n10)
"14"

> (rrep (list n14 n7) n10)
"14/7"

> (set n16 '(t t t t t t t t t t t t t t t t))
!IGNORE: output of set

> (rrep (list n14 n7) n16)
"e/7"

