#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 8;

{
    is_bel_output("(recip (lit num (+ (t) (t)) (+ nil (t))))", "1");
    is_bel_output("(recip (lit num (- (t) (t)) (+ nil (t))))", "-1");
    is_bel_output("(recip (lit num (+ (t t) (t)) (+ nil (t))))", "1/2");
    is_bel_output("(recip (lit num (- (t t t) (t)) (+ nil (t))))", "-1/3");
    is_bel_output("(recip (lit num (+ nil (t)) (+ (t) (t))))", "-i");
    is_bel_output("(recip (lit num (+ nil (t)) (- (t) (t))))", "+i");
    is_bel_output("(recip (lit num (+ (t t t) (t)) (+ (t t t t) (t))))", "3/25-4/25i");
    is_bel_error("(recip 0)", "'mistype");
}
