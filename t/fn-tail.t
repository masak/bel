#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (tail idfn nil)
nil

> (tail car '(a b c))
(a b c)

> (tail car '(nil b c))
(b c)

> (tail no:cdr '(a b c))
(c)

> (tail [caris _ \-] "non-nil")
"-nil"

