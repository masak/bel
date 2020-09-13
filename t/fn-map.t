#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(map car '((a b) (c d) (e f)))", "(a c e)");
    is_bel_output("(map cons '(a b c) '(1 2 3))", "((a . 1) (b . 2) (c . 3))");
    is_bel_output("(map cons '(a b c) '(1 2))", "((a . 1) (b . 2))");
    is_bel_output("(map join)", "nil");
    is_bel_output("(map list '(1 2) '(a b . c))", "((1 a) (2 b))");
}
