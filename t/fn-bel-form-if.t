#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(if))
nil

> (bel '(if 'a))
a

> (bel '(if 'a 'b))
b

> (bel '(if 'a 'b 'c))
b

> (bel '(if nil 'b 'c))
c

