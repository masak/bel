#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(aif)", "nil");
    is_bel_output("(aif 'a (list it 'b))", "(a b)");
    is_bel_output("(aif 'a (list 'b it) 'c)", "(b a)");
}
