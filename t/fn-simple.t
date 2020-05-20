#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(simple 'x)", "t");
    is_bel_output("(simple \\c)", "t");
    is_bel_output("(simple nil)", "t");
    is_bel_output("(simple '(a b))", "nil");
    is_bel_output("(simple 3)", "t");
    is_bel_output(q[(simple "ab")], "nil");
}
