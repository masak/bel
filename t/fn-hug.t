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
    is_bel_output("(hug '(a b c d))", "((a b) (c d))");
    is_bel_output("(hug '(a b c d e))", "((a b) (c d) (e))");
    is_bel_output("(hug '(a b c d) cons)", "((a . b) (c . d))");
    is_bel_output("(hug '(a b c d e) cons)", "((a . b) (c . d) e)");
}
