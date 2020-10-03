#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (caddr nil)
nil

> (caddr '(a))
nil

> (caddr '(a b))
nil

> (caddr '(a b c))
c

