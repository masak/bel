#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(iflet x)", "nil");
    is_bel_output("(iflet y 'a (list y 'b))", "(a b)");
    is_bel_output("(iflet z 'a (list 'b z) 'c)", "(b a)");
}
