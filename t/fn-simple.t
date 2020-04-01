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
    is_bel_output("(simple 'x)", "t");
    is_bel_output("(simple \\c)", "t");
    is_bel_output("(simple nil)", "t");
    is_bel_output("(simple '(a b))", "nil");
    is_bel_output("(simple 3)", "t");
    is_bel_output(q[(simple "ab")], "nil");
}
