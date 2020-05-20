#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(or)", "nil");
    is_bel_output("(or nil)", "nil");
    is_bel_output("(or nil t)", "t");
    is_bel_output("(or nil 'a)", "a");
    is_bel_output("(or nil 'b 'c)", "b");
}
