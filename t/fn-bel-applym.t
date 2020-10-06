#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '((lit mac (lit clo nil (x) x)) t))
t

