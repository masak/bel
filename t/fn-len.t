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
    is_bel_output("(len nil)", "0");
    is_bel_output("(len '(t))", "1");
    is_bel_output("(len '(t t))", "2");
    is_bel_output("(len '(t t t))", "3");
    is_bel_output("(len '(t t t t))", "4");
}
