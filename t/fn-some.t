#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(some atom '(a b c))", "(a b c)");
    is_bel_output("(some atom '())", "nil");
    is_bel_output("(some (lit clo nil (x) (id x 'b)) '(a b c))", "(b c)");
    is_bel_output("(some (lit clo nil (x) (id x 'q)) '(a b c))", "nil");
    is_bel_output("(some no '(t t nil))", "(nil)");
    is_bel_output("(some no '(t t))", "nil");
}
