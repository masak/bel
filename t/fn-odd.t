#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 9;

{
    is_bel_output("(odd 0)", "nil");
    is_bel_output("(odd \\x)", "nil");
    is_bel_output("(odd -1)", "t");
    is_bel_output("(odd \\0)", "nil");
    is_bel_output("(odd 1/2)", "nil");
    is_bel_output("(odd 4/2)", "nil");
    is_bel_output("(odd 6/2)", "t");
    is_bel_output("(odd 3)", "t");
    is_bel_output("(odd 4)", "nil");
}
