#!perl -w
# -T
use 5.006;
use strict;
use Language::Bel::Test::DSL;

__DATA__

> ((lit clo nil ((a b c)) c) '(a b c))
c

> ((lit clo nil ((a b c)) c) 'not-a-list)
!ERROR: atom-arg

> ((fn ((a b c)) c) '(a b c))
c

> ((fn ((a b c)) c) 'not-a-list)
!ERROR: atom-arg

