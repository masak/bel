#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output("(do (def foo (x) x) (foo 'a))", "a");
    is_bel_output("(do (def bar (x) (cons x x)) (bar 'a))", "(a . a)");
}
