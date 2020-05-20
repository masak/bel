#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 8;

{
    is_bel_output("(even 0)", "t");
    is_bel_error("(even \\x)", "cdr-on-atom");
    is_bel_output("(even -1)", "nil");
    is_bel_error("(even \\0)", "cdr-on-atom");
    is_bel_output("(even 1/2)", "nil");
    is_bel_output("(even 4/2)", "t");
    is_bel_output("(even 3)", "nil");
    is_bel_output("(even 4)", "t");
}
