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
    bel_todo("(< \\a \\c)", "t", "('unboundb chars)");
    bel_todo("(< \\d \\b)", "nil", "('unboundb chars)");
    bel_todo(q[(< "aa" "ac")], "t", "('unboundb chars)");
    bel_todo(q[(< "bc" "ab")], "nil", "('unboundb chars)");
    bel_todo("(< 'aa 'ac)", "t", "('unboundb chars)");
    bel_todo("(< 'bc 'ab)", "nil", "('unboundb chars)");
}
