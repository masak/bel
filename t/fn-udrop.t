#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(udrop nil nil)", "nil");
    is_bel_output("(udrop nil '(a b c))", "(a b c)");
    is_bel_output("(udrop '(x) '(a b c))", "(b c)");
    is_bel_output("(udrop '(x y z w) '(a b c))", "nil");
}
