#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (nom 'a)
"a"

> (nom \a)
!ERROR: not-a-symbol

> (nom nil)
"nil"

> (nom '(a))
!ERROR: not-a-symbol

> (nom "a")
!ERROR: not-a-symbol

