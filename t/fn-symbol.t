#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(symbol 'x)", "t");
    is_bel_output("(symbol nil)", "t");
    is_bel_output("(symbol '(a))", "nil");
    is_bel_output("(symbol (join))", "nil");
    is_bel_output("(symbol \\c)", "nil");
}
