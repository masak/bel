#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (rev nil)
nil

> (rev '(a b c))
(c b a)

> (rev '(a (x y) c))
(c (x y) a)

