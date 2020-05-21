#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(buildnum '(+ (t) (t)) '(+ nil (t)))", "1");
    is_bel_output("(buildnum '(+ (t t) (t t)) '(+ nil (t)))", "1");
    is_bel_output("(cadr (caddr (buildnum '(+ (t t) (t t)) '(+ nil (t)))))", "(t)");
    is_bel_output("(cadr (caddr (buildnum '(+ (t t t t) (t t t t t t)) '(+ nil (t)))))", "(t t)");
}
