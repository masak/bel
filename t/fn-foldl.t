#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(foldl cons nil '(a b))", "(b a)");
    is_bel_output("(foldl cons (cons 'a nil) '(b))", "(b a)");
    is_bel_output("(foldl cons (cons 'b (cons 'a nil)) nil)", "(b a)");
    is_bel_output("(foldl put nil '(a b c) '(x y z))", "((c . z) (b . y) (a . x))");
    is_bel_output("(foldl err nil)", "nil");
}
