#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(and)", "t");
    is_bel_output("(and nil)", "nil");
    is_bel_output("(and t)", "t");
    is_bel_output("(and 'a)", "a");
    is_bel_output("(and 'b nil 'c)", "nil");
}
