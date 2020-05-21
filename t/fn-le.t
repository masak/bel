#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(<= 1 1 1)", "t");
    is_bel_output("(<= 3 2 0)", "nil");
    is_bel_output("(<= 1 2 3)", "t");
    is_bel_output("(<= 1 2 1)", "nil");
    is_bel_output("(<= 1)", "t");
    is_bel_output("(<=)", "t");
}
