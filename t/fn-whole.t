#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 7;

{
    is_bel_output("(whole 0)", "t");
    is_bel_output("(whole \\x)", "nil");
    is_bel_output("(whole -1)", "nil");
    is_bel_output("(whole 1)", "t");
    is_bel_output("(whole 1/2)", "nil");
    is_bel_output("(whole 4/2)", "t");
    is_bel_output("(whole -4/2)", "nil");
}
