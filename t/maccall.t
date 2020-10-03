#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> ((lit mac (lit clo nil (x) (list 'cons nil x))) 'a)
(nil . a)

> ((lit mac (lit clo nil (x) (list 'cons nil x))) 'b)
(nil . b)

