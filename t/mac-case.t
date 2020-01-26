#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 10;

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
    is_bel_output("(let x 'a (case x a 'm))", "m");
    is_bel_output("(let x 'b (case x a 'm))", "nil");
    is_bel_output("(let x 'a (case x a 'm 'n))", "m");
    is_bel_output("(let x 'b (case x a 'm 'n))", "n");
    is_bel_output("(let x 'a (case x a 'm b 'n))", "m");
    is_bel_output("(let x 'b (case x a 'm b 'n))", "n");
    is_bel_output("(let x 'c (case x a 'm b 'n))", "nil");
    is_bel_output("(let x 'a (case x a 'm b 'n 'o))", "m");
    is_bel_output("(let x 'b (case x a 'm b 'n 'o))", "n");
    is_bel_output("(let x 'c (case x a 'm b 'n 'o))", "o");
}
