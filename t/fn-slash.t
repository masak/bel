#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 10;

{
    is_bel_output("(/)", "1");
    is_bel_output("(/ 5)", "5");
    is_bel_output(
        "(/ (lit num (+ (t) (t)) (+ nil (t))) (lit num (+ (t) (t)) (+ nil (t))))",
        "1");
    is_bel_output(
        "(/ (lit num (+ (t) (t)) (+ nil (t))) (lit num (- (t) (t)) (+ nil (t))))",
        "-1");
    is_bel_output(
        "(/ (lit num (+ (t) (t)) (+ nil (t))) (lit num (+ nil (t)) (+ (t t t) (t))))",
        "-1/3i");
    is_bel_output(
        "(/ (lit num (- (t) (t t)) (+ nil (t))) (lit num (+ nil (t)) (- (t t) (t t t))))",
        "-3/4i");
    is_bel_output("(/ 1 1)", "1");
    is_bel_output("(/ 1 -1)", "-1");
    is_bel_output("(/ 1 +3i)", "-1/3i");
    is_bel_output("(/ -1/2 -2/3i)", "-3/4i");
}
