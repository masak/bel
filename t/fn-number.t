#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 8;

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
    is_bel_output("(number '())", "nil");
    is_bel_output("(number (lit))", "nil");
    is_bel_output("(number (lit num))", "nil");
    is_bel_output("(number (lit num (+ nil (t))))", "nil");
    is_bel_output("(number (lit num (+ nil (t)) (+ nil)))", "nil");
    is_bel_output("(number (lit num (+ nil (t)) (+ nil (t))))", "t");
    is_bel_output("(number (lit num (+ (t) (t)) (+ nil (t))))", "t");
    is_bel_output("(number (lit num (+ (t t) (t t t)) (+ (t t t) (t))))", "t");
}
