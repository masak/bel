#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(i^ i0 i0)", "(t)");
    is_bel_output("(i^ i0 i1)", "nil");
    is_bel_output("(i^ i1 i0)", "(t)");
    is_bel_output("(i^ i1 i2)", "(t)");
    is_bel_output("(i^ i10 i1)", "(" . (join " ", ("t") x 10) . ")");
    is_bel_output("(i^ i2 '(t t t))", "(" . (join " ", ("t") x 8) . ")");
}
