#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(pair 'x)", "nil");
    is_bel_output("(pair nil)", "nil");
    is_bel_output("(pair '(a))", "t");
    is_bel_output("(pair (join))", "t");
    is_bel_output("(pair \\c)", "nil");
}
