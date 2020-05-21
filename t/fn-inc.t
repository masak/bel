#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(inc 0)", "1");
    is_bel_output("(inc 1)", "2");
    is_bel_output("(inc 3)", "4");
    is_bel_output("(inc -1)", "0");
    is_bel_output("(inc -4.5)", "-7/2");
    is_bel_output("(inc .5)", "3/2");
}
