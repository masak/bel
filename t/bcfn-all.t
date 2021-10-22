#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!all atom '(a b c))
t

> (bcfn!all atom '(a (b c) d))
nil

> (bcfn!all atom '())
t

> (bcfn!all no '(nil nil nil))
t

