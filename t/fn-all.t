#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (all atom '(a b c))
t

> (all atom '(a (b c) d))
nil

> (all atom '())
t

> (all no '(nil nil nil))
t

