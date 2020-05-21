#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(dec 0)", "-1");
    is_bel_output("(dec 1)", "0");
    is_bel_output("(dec 3)", "2");
    is_bel_output("(dec -1)", "-2");
    is_bel_output("(dec -4.5)", "-11/2");
    is_bel_output("(dec .5)", "-1/2");
}
