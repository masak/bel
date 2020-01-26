#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 3;

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
    is_bel_output("(let l '((a . 1) (b . 2) (c . 3)) (get 'b l))", "(b . 2)");
    is_bel_output("(let l '((a . 1) (b . 2) (c . 3)) (get 'd l))", "nil");
    is_bel_output("(let l nil (get 'x l))", "nil");
}
