#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("((cand atom no) nil)", "t");
    is_bel_output("((cand atom no) t)", "nil");
    is_bel_output("((cand atom) t)", "t");
    is_bel_output("((cand atom) (join))", "nil");
    is_bel_output("((cand) nil)", "t");
}
