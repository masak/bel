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
    is_bel_output("(srden (list '+ i1 i1))", "(t)");
    is_bel_output("(srden (list '- i1 i1))", "(t)");
    is_bel_output("(srden (list '+ i0 i1))", "(t)");
    is_bel_output("(srden (list '+ i2 i1))", "(t)");
    is_bel_output("(srden (list '+ '(t t t) i1))", "(t)");
    is_bel_output("(srden (list '- i2 '(t t t)))", "(t t t)");
    is_bel_output("(srden (list '+ i16 i0))", "nil");
}
