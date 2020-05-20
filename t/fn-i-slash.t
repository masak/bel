#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(i/ i0 i1)", "(nil nil)");
    is_bel_output("(i/ i1 i2)", "(nil (t))");
    is_bel_output("(i/ i10 i1)", "((" . (join " ", ("t") x 10) . ") nil)");
    is_bel_output("(i/ i2 i10)", "(nil (t t))");
    is_bel_output("(i/ i16 '(t t t))", "((t t t t t) (t))");
}
