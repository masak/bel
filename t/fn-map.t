#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 4;

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
    is_bel_output("(map car '((a b) (c d) (e f)))", "(a c e)");
    is_bel_output("(map cons '(a b c) '(1 2 3))", "((a . 1) (b . 2) (c . 3))");
    is_bel_output("(map cons '(a b c) '(1 2))", "((a . 1) (b . 2))");
    is_bel_output("(map join)", "nil");
}
