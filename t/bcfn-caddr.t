#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!caddr nil)
nil

> (bcfn!caddr '(a))
nil

> (bcfn!caddr '(a b))
nil

> (bcfn!caddr '(a b c))
c

