#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

This test is so slow it ends up in its own .t file.

> (bel '(list 'a (ccc (lit clo nil (c) 'b))))
(a b)

