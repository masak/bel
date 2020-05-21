#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 10;

{
    is_bel_output("(= '() '())", "t");
    is_bel_output("(= 'x 'x)", "t");
    is_bel_output("(= 'x 'y)", "nil");
    is_bel_output("(= 'x '(x))", "nil");
    is_bel_output("(= '(a b c) '(a b c))", "t");
    is_bel_output("(= '(a b d) '(a b c))", "nil");
    is_bel_output("(= '(a b) '(a b c))", "nil");
    is_bel_output("(= '(a b c) '(a b))", "nil");
    is_bel_output("(= '(a b (x y)) '(a b (x y)))", "t");
    is_bel_output("(= '(a b (x y)) '(a b (x z)))", "nil");
}
