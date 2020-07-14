#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 17;

{
    is_bel_output("(if (digit \\0) t)", "t");
    is_bel_output("(if (digit \\7) t)", "t");
    is_bel_output("(if (digit \\9) t)", "t");
    is_bel_output("(if (digit \\0 i10) t)", "t");
    is_bel_output("(if (digit \\7 i10) t)", "t");
    is_bel_output("(if (digit \\9 i10) t)", "t");
    is_bel_output("(if (digit \\a) t)", "nil");
    is_bel_output("(if (digit \\a i16) t)", "t");
    is_bel_output("(if (digit \\b) t)", "nil");
    is_bel_output("(if (digit \\b i16) t)", "t");
    is_bel_output("(if (digit \\f) t)", "nil");
    is_bel_output("(if (digit \\f i16) t)", "t");
    is_bel_output("(if (digit \\g) t)", "nil");
    is_bel_output("(if (digit \\g i16) t)", "nil");
    is_bel_output("(let i8 '(t t t t t t t t) (if (digit \\0 i8) t))", "t");
    is_bel_output("(let i8 '(t t t t t t t t) (if (digit \\7 i8) t))", "t");
    is_bel_output("(let i8 '(t t t t t t t t) (if (digit \\9 i8) t))", "nil");
}
