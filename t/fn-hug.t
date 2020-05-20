#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(hug '(a b c d))", "((a b) (c d))");
    is_bel_output("(hug '(a b c d e))", "((a b) (c d) (e))");
    is_bel_output("(hug '(a b c d) cons)", "((a . b) (c . d))");
    is_bel_output("(hug '(a b c d e) cons)", "((a . b) (c . d) e)");
}
