#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (string nil)
t

> (string "")
t

> (string "hello bel")
t

> (string 'c)
nil

> (string \a)
nil

