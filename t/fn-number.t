#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 8;

{
    is_bel_output("(number '())", "nil");
    is_bel_output("(number (lit))", "nil");
    is_bel_output("(number (lit num))", "nil");
    is_bel_output("(number (lit num (+ nil (t))))", "nil");
    is_bel_output("(number (lit num (+ nil (t)) (+ nil)))", "nil");
    is_bel_output("(number (lit num (+ nil (t)) (+ nil (t))))", "t");
    is_bel_output("(number (lit num (+ (t) (t)) (+ nil (t))))", "t");
    is_bel_output("(number (lit num (+ (t t) (t t t)) (+ (t t t) (t))))", "t");
}
