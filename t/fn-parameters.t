#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 10;

{
    is_bel_output("(parameters nil)", "nil");
    is_bel_output("(parameters 'foo)", "(foo)");
    is_bel_output("(parameters 'bar)", "(bar)");
    is_bel_error("(parameters \\c)", "bad-parm");
    is_bel_output("(parameters '(t one))", "(one)");
    is_bel_output("(parameters '(o two))", "(two)");
    is_bel_output("(parameters '(one two three))", "(one two three)");
    is_bel_output("(parameters '((((one)))))", "(one)");
    is_bel_output("(parameters '((((one)) two) three))", "(one two three)");
    is_bel_output("(parameters '((((one)) (o two)) three))", "(one two three)");
}
