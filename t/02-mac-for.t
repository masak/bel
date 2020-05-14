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
    is_bel_output("(let L nil (for n 1 5 (push n L)) L)", "(5 4 3 2 1)");
    is_bel_output("(let L nil (for n 3 3 (push n L)) L)", "(3)");
    is_bel_output("(let L nil (for n 4 1 (push n L)) L)", "nil");
}
