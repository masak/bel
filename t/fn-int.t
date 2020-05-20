#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(int 0)", "t");
    is_bel_output("(int \\x)", "nil");
    is_bel_output("(int -1)", "t");
    is_bel_output("(int \\0)", "nil");
    is_bel_output("(int 1/2)", "nil");
    is_bel_output("(int 4/2)", "t");
}
