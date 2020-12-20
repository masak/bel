#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (catch
    (throw 'a)
    (/ 1 0))
a

