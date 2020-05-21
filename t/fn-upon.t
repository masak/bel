#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(function (upon '(a b c)))", "clo");
    is_bel_output("((upon '(a b c)) cdr)", "(b c)");
    is_bel_output("(map (upon '(a b c)) (list car cadr cdr))", "(a b (b c))");
}
