#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(withs () (cons 'b 'a))", "(b . a)");
    is_bel_output("(withs (x 'a y 'b) (cons x y))", "(a . b)");
    is_bel_output("(withs (x 'a y x) (cons x y))", "(a . a)");
    is_bel_output("(let x 'a (withs (x x y x) y))", "a");
}
