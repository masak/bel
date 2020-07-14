#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 8;

{
    is_bel_output("(signc nil)", "nil");
    is_bel_output("(signc \\0)", "nil");
    is_bel_output("(signc \\a)", "nil");
    is_bel_output("(if (signc \\+) t)", "t");
    is_bel_output("(if (signc \\-) t)", "t");
    is_bel_output("(signc \\;)", "nil");
    is_bel_output("(signc \\3)", "nil");
    is_bel_output("(signc \\D)", "nil");
}
