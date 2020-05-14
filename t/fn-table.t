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
    is_bel_output("(table)", "(lit tab)");
    is_bel_output("(table nil)", "(lit tab)");
    is_bel_output("(table '((a . b)))", "(lit tab (a . b))");
    is_bel_output("(table '((a . b) (c . nil)))", "(lit tab (a . b) (c))");
    is_bel_output("(table '((a . b) (c . d)))", "(lit tab (a . b) (c . d))");
    is_bel_output("(table '((a . b) (a . d)))", "(lit tab (a . b) (a . d))");
    is_bel_output("(table '((a . 1) (b . 2)))", "(lit tab (a . 1) (b . 2))");
}
