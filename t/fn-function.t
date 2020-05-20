#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 8;

{
    is_bel_output("(function (fn (x) x))", "clo");
    is_bel_output("(function [_])", "clo");
    is_bel_output("(function idfn)", "clo");
    is_bel_output("(function car)", "prim");
    is_bel_output("(function nil)", "nil");
    is_bel_output("(function 'c)", "nil");
    is_bel_output("(function '(a b c))", "nil");
    is_bel_output("(function def)", "nil");
}
