#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(abs (lit num (+ nil (t)) (+ nil (t))))", "0");
    is_bel_output("(abs (lit num (+ nil (t)) (+ (t) (t))))", "0");
    is_bel_output("(abs (lit num (+ (t) (t)) (+ nil (t))))", "1");
    is_bel_output("(abs (lit num (- (t) (t)) (+ nil (t))))", "1");
    is_bel_output("(abs (lit num (+ (t t) (t t t)) (- (t) (t t t t))))", "2/3");
    is_bel_output("(abs (lit num (- (t t) (t t t)) (+ (t) (t t t t))))", "2/3");
}
