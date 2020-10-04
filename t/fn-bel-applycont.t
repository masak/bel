#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(join 'a (ccc (lit clo nil (c) (c 'b)))))
(a . b)

