#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(floor 3.5)", "3");
    is_bel_output("(floor 3)", "3");
    is_bel_output("(floor -3.5)", "-4");
    is_bel_output("(floor -3)", "-3");
}
