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
    is_bel_output("(whenlet x nil)", "nil");
    is_bel_output("(whenlet y 'a (list y 'b))", "(a b)");
    is_bel_output("(whenlet z 'a (list 'b z) 'c)", "c");
    is_bel_output("(whenlet z nil (list 'b z) 'c)", "nil");
}
