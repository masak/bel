#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 8;

{
    is_bel_output("(clog2 0)", "1");
    is_bel_output("(clog2 1)", "1");
    is_bel_output("(clog2 2)", "1");
    is_bel_output("(clog2 3)", "2");
    is_bel_output("(clog2 4)", "2");
    is_bel_output("(clog2 7)", "3");
    is_bel_output("(clog2 8)", "3");
    is_bel_output("(clog2 11)", "4");
}
