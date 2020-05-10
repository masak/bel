#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 7;

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
    is_bel_output("(whole 0)", "t");
    is_bel_output("(whole \\x)", "nil");
    is_bel_output("(whole -1)", "nil");
    is_bel_output("(whole 1)", "t");
    is_bel_output("(whole 1/2)", "nil");
    is_bel_output("(whole 4/2)", "t");
    is_bel_output("(whole -4/2)", "nil");
}
