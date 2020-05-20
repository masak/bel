#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(consif 'a nil)", "(a)");
    is_bel_output("(consif 'a '(b))", "(a b)");
    is_bel_output("(consif 'a '(b c))", "(a b c)");
    is_bel_output("(consif nil nil)", "nil");
    is_bel_output("(consif nil '(b))", "(b)");
    is_bel_output("(consif nil '(b c))", "(b c)");
}
