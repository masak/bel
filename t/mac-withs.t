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
    is_bel_output("(withs () (cons 'b 'a))", "(b . a)");
    is_bel_output("(withs (x 'a y 'b) (cons x y))", "(a . b)");
    is_bel_output("(withs (x 'a y x) (cons x y))", "(a . a)");
    is_bel_output("(let x 'a (withs (x x y x) y))", "a");
}
