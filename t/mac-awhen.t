#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(awhen nil)", "nil");
    is_bel_output("(awhen 'a (list it 'b))", "(a b)");
    is_bel_output("(awhen 'a (list 'b it) 'c)", "c");
    is_bel_output("(awhen nil (list 'b it) 'c)", "nil");
}
