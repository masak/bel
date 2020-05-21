#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(append '(a b c) '(d e f))", "(a b c d e f)");
    is_bel_output("(append '(a) nil '(b c) '(d e f))", "(a b c d e f)");
    is_bel_output("(append)", "nil");
}
