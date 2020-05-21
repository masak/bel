#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 8;

{
    is_bel_output("(~~whitec \\sp)", "t");
    is_bel_output("(~~whitec \\lf)", "t");
    is_bel_output("(~~whitec \\tab)", "t");
    is_bel_output("(~~whitec \\cr)", "t");
    is_bel_output("(~~whitec \\a)", "nil");
    is_bel_output("(~~whitec \\b)", "nil");
    is_bel_output("(~~whitec \\x)", "nil");
    is_bel_output("(~~whitec \\1)", "nil");
}
