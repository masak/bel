#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 9;

{
    is_bel_output("(srrecip (list '+ i1 i1))", "(+ (t) (t))");
    is_bel_output("(srrecip (list '- i1 i1))", "(- (t) (t))");
    is_bel_error("(srrecip (list '+ i0 i1))", "'mistype");
    is_bel_output("(srrecip (list '+ i2 i1))", "(+ (t) (t t))");
    is_bel_output("(srrecip (list '- i2 i1))", "(- (t) (t t))");
    is_bel_output("(srrecip (list '+ i1 i2))", "(+ (t t) (t))");
    is_bel_output("(srrecip (list '+ i2 '(t t t)))", "(+ (t t t) (t t))");
    is_bel_output("(srrecip (list '- i2 i2))", "(- (t t) (t t))");
    is_bel_output("(srrecip (list '+ i2 i0))", "(+ nil (t t))");
}
