#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (atom \a)
t

> (atom nil)
t

> (atom 'a)
t

> (atom '(a))
nil

