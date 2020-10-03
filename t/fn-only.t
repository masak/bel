#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> ((only cons) nil 'a 'b 'c)
nil

> ((only cons) 'a 'b 'c)
(a b . c)

> ((compose (only car) some) is!b '(a b c))
b

> ((compose (only car) some) is!z '(a b c))
nil

