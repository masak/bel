#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(round -2.5)", "-2");
    is_bel_output("(round -1.5)", "-2");
    is_bel_output("(round -1.4)", "-1");
    is_bel_output("(round 1.4)", "1");
    is_bel_output("(round 1.5)", "2");
    is_bel_output("(round 2.5)", "2");
}
