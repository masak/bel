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
    is_bel_output("((only cons) nil 'a 'b 'c)", "nil");
    is_bel_output("((only cons) 'a 'b 'c)", "(a b . c)");
    is_bel_output("((compose (only car) some) [= _ 'b] '(a b c))", "b");
    is_bel_output("((compose (only car) some) [= _ 'z] '(a b c))", "nil");
}
