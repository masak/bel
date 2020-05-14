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
    is_bel_output("(round -2.5)", "-2");
    is_bel_output("(round -1.5)", "-2");
    is_bel_output("(round -1.4)", "-1");
    is_bel_output("(round 1.4)", "1");
    is_bel_output("(round 1.5)", "2");
    is_bel_output("(round 2.5)", "2");
}
