#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> '(#1=(nil) #1)
(#1=(nil) #1)

> '#1=(nil . #1)
#1=(nil . #1)

> '#2=(nil . #2)
#1=(nil . #1)

> #1
!ERROR: unknown-label

> '(a #1)
!ERROR: unknown-label

> '#1=(4 5 6 . #1)
#1=(4 5 6 . #1)

> '#1=(hi there . #1)
#1=(hi there . #1)

