#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 10;

{
    is_bel_output("(((combine and) atom no) nil)", "t");
    is_bel_output("(((combine and) atom no) t)", "nil");
    is_bel_output("(((combine and) atom) t)", "t");
    is_bel_output("(((combine and) atom) (join))", "nil");
    is_bel_output("(((combine and)) nil)", "t");
    is_bel_output("(((combine or) pair no) nil)", "t");
    is_bel_output("(((combine or) pair no) t)", "nil");
    is_bel_output("(((combine or) pair no) '(x y))", "t");
    is_bel_output("(((combine or) pair) (join))", "t");
    is_bel_output("(((combine or)) nil)", "nil");
}
