#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(cons 'a nil)", "(a)");
    is_bel_output("(cons 'a)", "a");
    is_bel_output("(cons 'a 'b)", "(a . b)");
    is_bel_output("(cons)", "nil");
    is_bel_output("(cons 'a 'b 'c '(d e f))", "(a b c d e f)");
}
