#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (aif)
nil

> (aif 'a (list it 'b))
(a b)

> (aif 'a (list 'b it) 'c)
(b a)

