#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (drop 2 '(a b c))
(c)

> (drop 0 '(a b c))
(a b c)

If you drop more from the list than is available, you get `nil`.

> (drop 5 '(a b c))
nil

> (drop 2 nil)
nil

