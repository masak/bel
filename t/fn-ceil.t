#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(ceil 3.5)", "4");
    is_bel_output("(ceil 3)", "3");
    is_bel_output("(ceil -3.5)", "-3");
    is_bel_output("(ceil -3)", "-3");
}
