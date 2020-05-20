#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    my $empty_string = "";
    is_bel_output("(string nil)", "t");
    is_bel_output(q[(string "")], "t");
    is_bel_output(q[(string "hello bel")], "t");
    is_bel_output("(string 'c)", "nil");
    is_bel_output("(string \\a)", "nil");
}
