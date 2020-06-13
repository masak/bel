#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 7;

{
    is_bel_output("(okenv nil)", "t");
    is_bel_output("(okenv '(a . b))", "nil");
    is_bel_output("(okenv '(a))", "nil");
    is_bel_output("(okenv '((a . b)))", "t");
    is_bel_output("(okenv '((a . b) (c . d)))", "t");
    is_bel_output("(okenv '((a . b) nil (c . d)))", "nil");
    is_bel_output("(okenv '((a . b) (nil) (c . d)))", "t");
}
