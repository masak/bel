#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("vmark", "(nil)");
    is_bel_output("(id vmark vmark)", "t");
    is_bel_output("(id vmark (join))", "nil");
    is_bel_output("(id vmark '(nil))", "nil");

    is_bel_output("(uvar)", "((nil))");
    is_bel_output("(id (uvar) (uvar))", "nil");
}
