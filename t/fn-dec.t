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
    is_bel_output("(dec 0)", "-1");
    is_bel_output("(dec 1)", "0");
    is_bel_output("(dec 3)", "2");
    is_bel_output("(dec -1)", "-2");
    is_bel_output("(dec -4.5)", "-11/2");
    is_bel_output("(dec .5)", "-1/2");
}
