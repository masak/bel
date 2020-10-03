#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (dock nil)
nil

> (dock '(a))
nil

> (dock '(a b))
(a)

> (dock '(a b c))
(a b)

