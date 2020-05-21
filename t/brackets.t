#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(atom [id _ t])", "nil");
    is_bel_output("([id _ 'd] 'd)", "t");
    is_bel_output("(map [car _] '((a b) (c d) (e f)))", "(a c e)");
    is_bel_output("([] t)", "nil");
}
