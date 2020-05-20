#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(last nil)", "nil");
    is_bel_output("(last '(a))", "a");
    is_bel_output("(last '(a b))", "b");
    is_bel_output("(last '(a b c))", "c");
    is_bel_output("(last '(a b nil))", "nil");
}
