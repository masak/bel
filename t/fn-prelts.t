#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (do
    (prelts '(1 2 3) outs nil nil)
    (prc \lf)
    nil)
1 2 3
nil

> (do
    (prelts '(a b . c) outs nil nil)
    (prc \lf)
    nil)
a b . c
nil

