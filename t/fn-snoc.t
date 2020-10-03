#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (snoc '(a b c) 'd 'e)
(a b c d e)

> (snoc '())
nil

> (snoc)
nil

