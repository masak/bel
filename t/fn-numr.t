#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(numr (lit num (+ nil (t)) (+ nil (t))))", "(+ nil (t))");
    is_bel_output("(numr (lit num (+ nil (t)) (+ (t) (t))))", "(+ nil (t))");
    is_bel_output("(numr (lit num (+ (t) (t)) (+ nil (t))))", "(+ (t) (t))");
    is_bel_output("(numr (lit num (+ (t t) (t t t)) (+ (t) (t t t t))))", "(+ (t t) (t t t))");
}
