#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (in 'e 'x 'y 'z)
nil

> (in 'b 'a 'b 'c)
(b c)

> (in nil 'a nil 'c)
(nil c)

