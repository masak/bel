#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(factor '(t t))", "((t t))");
    is_bel_output("(factor '(t t t))", "((t t t))");
    is_bel_output("(factor '(t t t t))", "((t t) (t t))");
    is_bel_output("(factor '(t t t t t))", "((t t t t t))");
    is_bel_output("(factor '(t t t t t t))", "((t t) (t t t))");
    is_bel_output("(factor '(t t t t t t t))", "((t t t t t t t))");
}
