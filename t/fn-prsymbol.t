#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (do
    (prsymbol 'hello outs)
    (prc \lf)
    nil)
hello
nil

