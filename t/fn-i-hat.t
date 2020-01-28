#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 6;

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
    is_bel_output("(i^ i0 i0)", "(t)");
    is_bel_output("(i^ i0 i1)", "nil");
    is_bel_output("(i^ i1 i0)", "(t)");
    is_bel_output("(i^ i1 i2)", "(t)");
    is_bel_output("(i^ i10 i1)", "(" . (join " ", ("t") x 10) . ")");
    is_bel_output("(i^ i2 '(t t t))", "(" . (join " ", ("t") x 8) . ")");
}
