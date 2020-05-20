#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(list)", "nil");
    is_bel_output("(list 'a)", "(a)");
    is_bel_output("(list 'a 'b)", "(a b)");
}
