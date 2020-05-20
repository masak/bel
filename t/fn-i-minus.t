#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(i- i0 i0)", "(- nil)");
    is_bel_output("(i- i0 i1)", "(- (t))");
    is_bel_output("(i- i1 i0)", "(+ (t))");
    is_bel_output("(i- i1 i2)", "(- (t))");
    is_bel_output("(i- i10 i1)", "(+ (t t t t t t t t t))");
    is_bel_output("(i- i2 i10)", "(- (t t t t t t t t))");
}
