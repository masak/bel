#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 13;

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
    is_bel_output("(lit num (+ nil (t)) (+ nil (t)))", "0");
    is_bel_output("(lit num (+ (t) (t)) (+ nil (t)))", "1");
    is_bel_output("(lit num (- (t) (t)) (+ nil (t)))", "-1");
    is_bel_output("(lit num (+ (t t) (t)) (+ nil (t)))", "2");
    is_bel_output("(lit num (+ (t) (t t)) (+ nil (t)))", "1/2");
    is_bel_output("(lit num (- (t) (t t)) (+ nil (t)))", "-1/2");
    is_bel_output("(lit num (+ nil (t)) (+ (t) (t)))", "+i");
    is_bel_output("(lit num (+ nil (t)) (- (t) (t)))", "-i");
    is_bel_output("(lit num (+ (t t) (t)) (+ (t t t) (t)))", "2+3i");
    is_bel_output("(lit num (- (t t) (t)) (+ (t t t) (t)))", "-2+3i");
    is_bel_output("(lit num (+ (t t) (t)) (- (t t t) (t)))", "2-3i");
    is_bel_output("(lit num (- (t t) (t)) (- (t t t) (t)))", "-2-3i");
    is_bel_output("(lit num (+ (t t t) (t t)) (+ (t) (t t t t)))", "3/2+1/4i");
}
