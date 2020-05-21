#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(simplify '(+ nil (t t t)))", "(+ nil (t))");
    is_bel_output("(simplify '(+ nil (t)))", "(+ nil (t))");
    is_bel_output("(simplify '(+ nil nil))", "(+ nil (t))");
    is_bel_output("(simplify '(+ (t t t t t t) (t t t t)))", "(+ (t t t) (t t))");
    is_bel_output("(simplify '(+ (t t t t t t) (t t t)))", "(+ (t t) (t))");
}
