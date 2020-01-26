#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 5;

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
    is_bel_output("(and)", "t");
    is_bel_output("(and nil)", "nil");
    is_bel_output("(and t)", "t");
    is_bel_output("(and 'a)", "a");
    is_bel_output("(and 'b nil 'c)", "nil");
}
