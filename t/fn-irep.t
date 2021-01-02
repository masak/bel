#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set n10 '(t t t t t t t t t t))
!IGNORE: output of set

> (irep nil n10)
"0"

> (set n7 '(t t t t t t t))
!IGNORE: output of set

> (irep n7 n10)
"7"

> (irep n10 n10)
"10"

> (set n14 '(t t t t t t t t t t t t t t))
!IGNORE: output of set

> (irep n14 n10)
"14"

> (set n16 '(t t t t t t t t t t t t t t t t))
!IGNORE: output of set

> (irep n16 n10)
"16"

> (irep n14 n16)
"e"

