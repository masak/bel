#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 8;

{
    is_bel_output("(^w 5 1)", "5");
    is_bel_output("(^w 5 0)", "1");
    is_bel_output("(^w 3 2)", "9");
    is_bel_output("(^w 2 3)", "8");
    is_bel_output("(^w 1.5 1)", "3/2");
    is_bel_output("(^w 1.5 0)", "1");
    is_bel_output("(^w 1.5 2)", "9/4");
    is_bel_error("(^w 5 -1)", "'mistype");
}
