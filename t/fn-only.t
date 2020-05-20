#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("((only cons) nil 'a 'b 'c)", "nil");
    is_bel_output("((only cons) 'a 'b 'c)", "(a b . c)");
    is_bel_output("((compose (only car) some) [= _ 'b] '(a b c))", "b");
    is_bel_output("((compose (only car) some) [= _ 'z] '(a b c))", "nil");
}
