#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(drop 2 '(a b c))", "(c)");
    is_bel_output("(drop 0 '(a b c))", "(a b c)");
    is_bel_output("(drop 5 '(a b c))", "nil");
    is_bel_output("(drop 2 nil)", "nil");
}
