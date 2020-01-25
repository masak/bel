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
    is_bel_output("(atom [id _ t])", "nil");
    is_bel_output("([id _ 'd] 'd)", "t");
    is_bel_output("(map [car _] '((a b) (c d) (e f)))", "(a c e)");
    is_bel_output("([] t)", "nil");
}
