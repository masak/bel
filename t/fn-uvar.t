#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> vmark
(nil)

> (id vmark vmark)
t

> (id vmark (join))
nil

> (id vmark '(nil))
nil

> (uvar)
((nil))

> (id (uvar) (uvar))
nil

> (id (car (uvar)) vmark)
t

