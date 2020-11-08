#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(nom 'a))
"a"

> (bel '(nom \a))
!ERROR: mistype

> (bel '(nom nil))
"nil"

> (bel '(nom '(a)))
!ERROR: mistype

> (bel '(nom "a"))
!ERROR: mistype

