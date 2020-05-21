#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(first 1 '(a b c))", "(a)");
    is_bel_output("(first 4 '(a b c))", "(a b c)");
    is_bel_output("(first 2 nil)", "nil");
}
