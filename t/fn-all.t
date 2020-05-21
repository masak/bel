#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(all atom '(a b c))", "t");
    is_bel_output("(all atom '(a (b c) d))", "nil");
    is_bel_output("(all atom '())", "t");
    is_bel_output("(all no '(nil nil nil))", "t");
}
