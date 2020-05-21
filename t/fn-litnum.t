#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(litnum '(+ nil (t)))", "0");
    is_bel_output("(litnum '(+ (t) (t)))", "1");
    is_bel_output("(litnum '(+ nil (t)) '(+ (t) (t)))", "+i");
}
