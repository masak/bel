#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("((part cons 'a) 'b)", "(a . b)");
    is_bel_output("((part list 1 2 3) 4 5)", "(1 2 3 4 5)");
    is_bel_output("((part no) t)", "nil");
    is_bel_output("((part no) nil)", "t");
}
