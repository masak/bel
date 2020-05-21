#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 10;

{
    is_bel_output("(no nil)", "t");
    is_bel_output("(no 'nil)", "t");
    is_bel_output("(no '())", "t");
    is_bel_output("(no t)", "nil");
    is_bel_output("(no 'x)", "nil");
    is_bel_output("(no \\c)", "nil");
    is_bel_output("(no '(nil))", "nil");
    is_bel_output("(no '(a . b))", "nil");
    is_bel_output("(no no)", "nil");
    is_bel_output("(no (no no))", "t");
}
