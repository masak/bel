#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(dock nil)", "nil");
    is_bel_output("(dock '(a))", "nil");
    is_bel_output("(dock '(a b))", "(a)");
    is_bel_output("(dock '(a b c))", "(a b)");
}
