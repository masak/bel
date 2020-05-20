#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(common '(a b c) '(d e f))", "nil");
    is_bel_output("(common '(a b c) '(d a f))", "(a)");
    is_bel_output("(common '(a b c) '(d a a))", "(a)");
    is_bel_output("(common '(a a c) '(d a a))", "(a a)");
    is_bel_output("(common '(2 2 5 5) '(2 3 5))", "(2 5)");
}
