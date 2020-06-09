#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 8;

{
    is_bel_output("(< 2 4)", "t");
    is_bel_output("(< 5 3)", "nil");
    is_bel_output("(< \\a \\c)", "t");
    is_bel_output("(< \\d \\b)", "nil");
    is_bel_output(q[(< "aa" "ac")], "t");
    is_bel_output(q[(< "bc" "ab")], "nil");
    is_bel_output("(< 'aa 'ac)", "t");
    is_bel_output("(< 'bc 'ab)", "nil");
}
