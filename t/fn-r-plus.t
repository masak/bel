#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(r+ (list i1 i1) (list i1 i1))", "((t t) (t))");
    is_bel_output("(r+ (list i0 i1) (list i0 i1))", "(nil (t))");
    is_bel_output("(r+ (list i2 i1) (list i2 i1))", "((t t t t) (t))");
    is_bel_output("(r+ (list i1 i2) (list i1 i2))", "((t t t t) (t t t t))");
    is_bel_output("(r+ (list i2 '(t t t)) (list '(t t t) i2))",
        "((" . (join " ", ("t") x 13) . ") (t t t t t t))");
    is_bel_output("(r+ (list i2 i0) (list '(t t t) i2))",
        "((t t t t) nil)");
}
