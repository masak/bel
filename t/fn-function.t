#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 8;

sub is_bel_output {
    my ($expr, $expected_output) = @_;

    my $actual_output = "";
    my $b = Language::Bel->new({ output => sub {
        my ($string) = @_;
        $actual_output = "$actual_output$string";
    } });
    $b->eval($expr);

    is($actual_output, $expected_output, "$expr ==> $expected_output");
}

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
