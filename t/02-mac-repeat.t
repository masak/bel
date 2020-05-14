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
    is_bel_output("(let L nil (repeat 5 (push 'hi L)) L)", "(hi hi hi hi hi)");
    is_bel_output("(let L nil (repeat 1 (push 'hi L)) L)", "(hi)");
    is_bel_output("(let L nil (repeat 0 (push 'hi L)) L)", "nil");
    is_bel_output("(let L nil (repeat -2 (push 'hi L)) L)", "nil");
}
