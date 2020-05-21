#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(whenlet x nil)", "nil");
    is_bel_output("(whenlet y 'a (list y 'b))", "(a b)");
    is_bel_output("(whenlet z 'a (list 'b z) 'c)", "c");
    is_bel_output("(whenlet z nil (list 'b z) 'c)", "nil");
}
