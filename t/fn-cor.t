#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> ((cor pair no) nil)
t

> ((cor pair no) t)
nil

> ((cor pair no) '(x y))
t

> ((cor pair) (join))
t

> ((cor) nil)
nil

