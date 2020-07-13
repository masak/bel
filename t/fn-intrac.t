#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 8;

{
    is_bel_output("(intrac nil)", "nil");
    is_bel_output("(intrac \\0)", "nil");
    is_bel_output("(intrac \\a)", "nil");
    is_bel_output("(if (intrac \\.) t)", "t");
    is_bel_output("(if (intrac \\!) t)", "t");
    is_bel_output("(intrac \\+)", "nil");
    is_bel_output("(intrac \\-)", "nil");
    is_bel_output("(intrac \\D)", "nil");
}
