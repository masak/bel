#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!atom \a)
t

> (bcfn!atom nil)
t

> (bcfn!atom 'a)
t

> (bcfn!atom '(a))
nil

