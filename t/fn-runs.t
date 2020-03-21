#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 14;

my $actual_output = "";
my $b = Language::Bel->new({ output => sub {
    my ($string) = @_;
    $actual_output = "$actual_output$string";
} });

sub is_bel_output {
    my ($expr, $expected_output) = @_;

    $actual_output = "";
    $b->eval($expr);

    is($actual_output, $expected_output, "$expr ==> $expected_output");
}

{
    is_bel_output("(runs [= _ 1] '(1 1 0 0 0 1 1 1 0)) ", "((1 1) (0 0 0) (1 1 1) (0))");
    is_bel_output("(runs [= _ 1] '()) ", "nil");
    is_bel_output("(runs [= _ 1] '(1)) ", "((1))");
    is_bel_output("(runs [= _ 1] '(0)) ", "((0))");
    is_bel_output("(runs [= _ 1] '(1 0)) ", "((1) (0))");
    is_bel_output("(runs [= _ 1] '(0 1)) ", "((0) (1))");
    is_bel_output("(runs [= _ 1] '(1) nil) ", "(nil (1))");
    is_bel_output("(runs [= _ 1] '(1) t) ", "((1))");
    is_bel_output("(runs [= _ 1] '(0) nil) ", "((0))");
    is_bel_output("(runs [= _ 1] '(0) t) ", "(nil (0))");
    is_bel_output("(runs [= _ 1] '(1 0) nil) ", "(nil (1) (0))");
    is_bel_output("(runs [= _ 1] '(1 0) t) ", "((1) (0))");
    is_bel_output("(runs [= _ 1] '(0 1) nil) ", "((0) (1))");
    is_bel_output("(runs [= _ 1] '(0 1) t) ", "(nil (0) (1))");
}
