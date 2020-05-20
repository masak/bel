#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 7;

{
    is_bel_output("(srden (list '+ i1 i1))", "(t)");
    is_bel_output("(srden (list '- i1 i1))", "(t)");
    is_bel_output("(srden (list '+ i0 i1))", "(t)");
    is_bel_output("(srden (list '+ i2 i1))", "(t)");
    is_bel_output("(srden (list '+ '(t t t) i1))", "(t)");
    is_bel_output("(srden (list '- i2 '(t t t)))", "(t t t)");
    is_bel_output("(srden (list '+ i16 i0))", "nil");
}
