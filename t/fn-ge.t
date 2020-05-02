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
    is_bel_output("(>= 1 1 1)", "t");
    is_bel_output("(>= 3 2 0)", "t");
    is_bel_output("(>= 1 2 3)", "nil");
    is_bel_output("(>= 1 2 1)", "nil");
    is_bel_output("(>= 1)", "t");
    is_bel_output("(>=)", "t");
}
