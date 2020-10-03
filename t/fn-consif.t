#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (consif 'a nil)
(a)

> (consif 'a '(b))
(a b)

> (consif 'a '(b c))
(a b c)

> (consif nil nil)
nil

> (consif nil '(b))
(b)

> (consif nil '(b c))
(b c)

