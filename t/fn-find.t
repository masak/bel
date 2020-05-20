#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(find atom '(a b c))", "a");
    is_bel_output("(find atom '())", "nil");
    is_bel_output("(find (fn (x) (id x 'b)) '(a b c))", "b");
    is_bel_output("(find (fn (x) (id x 'q)) '(a b c))", "nil");
    is_bel_output("(find no '(t t nil))", "nil");
    is_bel_output("(find no '(t t))", "nil");
}
