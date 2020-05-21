#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(reduce join '(a b c))", "(a b . c)");
    is_bel_output("(reduce (lit clo nil (x y) x) '(a b c))", "a");
    is_bel_output("(reduce (lit clo nil (x y) y) '(a b c))", "c");
    is_bel_output("(reduce join '())", "nil");
}
