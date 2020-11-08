#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (nom 'a)
"a"

> (nom \a)
!ERROR: mistype

> (nom nil)
"nil"

> (nom '(a))
!ERROR: mistype

> (nom "a")
!ERROR: mistype

