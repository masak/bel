#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 10;

{
    is_bel_output("(<= 0 (rand 2) 1)", "t");
    is_bel_output("(<= 0 (rand 2) 1)", "t");
    is_bel_output("(<= 0 (rand 2) 1)", "t");
    is_bel_output("(<= 0 (rand 6) 5)", "t");
    is_bel_output("(<= 0 (rand 6) 5)", "t");
    is_bel_output("(<= 0 (rand 6) 5)", "t");
    is_bel_output("(<= 0 (rand 11) 10)", "t");
    is_bel_output("(<= 0 (rand 11) 10)", "t");
    is_bel_output("(<= 0 (rand 11) 10)", "t");
    is_bel_error("(rand 0)", "'mistype");
}
