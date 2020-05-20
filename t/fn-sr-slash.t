#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 9;

{
    is_bel_output("(sr/ (list '+ i1 i1) (list '+ i1 i1))", "(+ (t) (t))");
    is_bel_output("(sr/ (list '+ i1 i1) (list '- i1 i1))", "(- (t) (t))");
    is_bel_output("(sr/ (list '+ i0 i1) (list '+ i2 i1))", "(+ nil (t t))");
    is_bel_output("(sr/ (list '+ i2 i1) (list '+ i2 i1))",
        "(+ (t t) (t t))");
    is_bel_output("(sr/ (list '+ i1 i1) (list '- i2 i1))", "(- (t) (t t))");
    is_bel_output("(sr/ (list '+ i1 i2) (list '+ i1 i2))",
        "(+ (t t) (t t))");
    is_bel_output("(sr/ (list '+ i2 '(t t t)) (list '+ '(t t t) i2))",
        "(+ (t t t t) (t t t t t t t t t))");
    is_bel_output("(sr/ (list '- i2 i2) (list '+ i1 i2))",
        "(- (t t t t) (t t))");
    is_bel_output("(sr/ (list '+ i2 i0) (list '+ '(t t t) i2))",
        "(+ (t t t t) nil)");
}
