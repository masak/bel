#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bin<)
nil

> (bin< nil)
nil

> (bin< nil nil nil)
nil

> (bin< 2)
!ERROR: underargs

> (bin< \x)
t

> (bin< "hi")
!ERROR: underargs

> (bin< 'cookie)
!ERROR: underargs

> (bin< 1 2)
(t)

> (bin< 3 2)
nil

> (bin< \F \G)
t

> (bin< \z \h)
nil

> (bin< "one" "two")
t

> (bin< "zwei" "eins")
nil

> (bin< 'coo 'kie)
t

> (bin< 'yum 'nom)
nil

> (bin< 1 2 0)
(t)

> (bin< \F \G \C)
nil

> (bin< "one" "uno" "ett")
t

> (bin< 'x 'y 'm)
!ERROR: overargs

> (bin< 0 'zero)
!ERROR: incomparable

> (bin< "x" \x)
!ERROR: incomparable

> (bin< t \t)
!ERROR: incomparable

