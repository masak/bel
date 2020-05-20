#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(mod 10 2)", "0");
    is_bel_output("(mod 10 3)", "1");
    is_bel_output("(mod 5 4)", "1");
    is_bel_output("(mod 6 4)", "2");
    is_bel_output("(mod 7 3.5)", "0");
    is_bel_output("(mod 8 3.5)", "1");
}
