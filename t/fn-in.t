#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(in 'e 'x 'y 'z)", "nil");
    is_bel_output("(in 'b 'a 'b 'c)", "(b c)");
    is_bel_output("(in nil 'a nil 'c)", "(nil c)");
}
