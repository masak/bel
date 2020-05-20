#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(char 'x)", "nil");
    is_bel_output("(char nil)", "nil");
    is_bel_output("(char '(a))", "nil");
    is_bel_output("(char (join))", "nil");
    is_bel_output("(char \\c)", "t");
}
