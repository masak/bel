#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 11;

{
    is_bel_output("(breakc nil)", "t");
    is_bel_output("(breakc \\0)", "nil");
    is_bel_output("(breakc \\a)", "nil");
    is_bel_output("(if (breakc \\sp) t)", "t");
    is_bel_output("(breakc \\;)", "t");
    is_bel_output("(breakc \\3)", "nil");
    is_bel_output("(if (breakc \\() t)", "t");
    is_bel_output("(if (breakc \\[) t)", "t");
    is_bel_output("(if (breakc \\)) t)", "t");
    is_bel_output("(if (breakc \\]) t)", "t");
    is_bel_output("(breakc \\D)", "nil");
}
